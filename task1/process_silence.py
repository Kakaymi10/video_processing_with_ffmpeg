import re
import subprocess

def parse_silence_log(log_file):
    with open(log_file, "r") as f:
        log = f.readlines()
    
    silence_intervals = []
    silence_start = None
    
    for line in log:
        start_match = re.search(r"silence_start: ([0-9.]+)", line)
        end_match = re.search(r"silence_end: ([0-9.]+)", line)
        
        if start_match:
            silence_start = float(start_match.group(1))
        if end_match:
            silence_end = float(end_match.group(1))
            if silence_start is not None:
                silence_intervals.append((silence_start, silence_end))
                silence_start = None

    return silence_intervals

def generate_ffmpeg_trim_commands(input_file, silence_intervals, output_file):
    total_duration = float(subprocess.check_output(
        f"ffprobe -i {input_file} -show_entries format=duration -v quiet -of csv=p=0",
        shell=True
    ).decode().strip())
    
    audio_parts = []
    prev_end = 0.0
    
    for start, end in silence_intervals:
        if start > prev_end:
            audio_parts.append((prev_end, start))
        prev_end = end
    
    if prev_end < total_duration:
        audio_parts.append((prev_end, total_duration))
    
    # Create FFmpeg commands
    filter_complex = ""
    for idx, (start, end) in enumerate(audio_parts):
        filter_complex += f"[0:v]trim=start={start}:end={end},setpts=PTS-STARTPTS[v{idx}];"
        filter_complex += f"[0:a]atrim=start={start}:end={end},asetpts=PTS-STARTPTS[a{idx}];"
    
    outputs = "".join(f"[v{idx}][a{idx}]" for idx in range(len(audio_parts)))
    command = (
        f"ffmpeg -i {input_file} -filter_complex \"{filter_complex}{outputs}concat=n={len(audio_parts)}:v=1:a=1[outv][outa]\" "
        f"-map \"[outv]\" -map \"[outa]\" {output_file}"
    )
    
    return command

# Input and output files
input_file = "jumpcut_edits.mp4"
output_file = "output1.mp4"
silence_log = "silence.log"

# Process log and generate FFmpeg command
silence_intervals = parse_silence_log(silence_log)
ffmpeg_command = generate_ffmpeg_trim_commands(input_file, silence_intervals, output_file)

# Run FFmpeg command
print("Running FFmpeg command...")
subprocess.run(ffmpeg_command, shell=True)
print(f"Output saved to {output_file}")

