#!/bin/bash

# Ensure a file name and fade-out duration are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_file> <fade_duration_in_seconds>"
  exit 1
fi

INPUT_FILE=$1
FADE_DURATION=$2
OUTPUT_FILE="output_with_fade.mp4"

# Get the total duration of the video/audio using FFprobe
TOTAL_DURATION=$(ffprobe -v error -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")

# Check if FFprobe returned a valid duration
if [ -z "$TOTAL_DURATION" ]; then
  echo "Failed to retrieve the duration of the input file."
  exit 1
fi

# Convert TOTAL_DURATION and FADE_DURATION to floating-point numbers
TOTAL_DURATION=$(printf "%.2f" "$TOTAL_DURATION")
FADE_DURATION=$(printf "%.2f" "$FADE_DURATION")

# Calculate the start time for the fade effect
FADE_START=$(echo "$TOTAL_DURATION - $FADE_DURATION" | bc)

# Validate FADE_START
if (( $(echo "$FADE_START < 0" | bc -l) )); then
  echo "Error: Fade duration is longer than the total duration of the file."
  exit 1
fi

# Debug output to check the calculated values
echo "Total Duration: $TOTAL_DURATION seconds"
echo "Fade Start Time: $FADE_START seconds"

# Apply the fade-out effect using FFmpeg
ffmpeg -i "$INPUT_FILE" -vf "fade=t=out:st=$FADE_START:d=$FADE_DURATION" \
  -af "afade=t=out:st=$FADE_START:d=$FADE_DURATION" -y "$OUTPUT_FILE"

# Check if FFmpeg successfully created the output file
if [ $? -eq 0 ]; then
  echo "Fade-out effect applied successfully. Output saved to $OUTPUT_FILE"
else
  echo "Failed to apply the fade-out effect."
  exit 1
fi
