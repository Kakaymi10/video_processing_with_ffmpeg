#!/bin/bash
ffmpeg -i vr_recording.mp4 -vf "crop=1920:1080,subtitles=vr_subs.srt" -c:v libx264 -crf 23 -preset fast -c:a aac -b:a 192k -shortest output.mp4
