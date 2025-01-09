#!/bin/bash

# Check if an image file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <input_image>"
  exit 1
fi

# Get the input image from the argument
INPUT_IMAGE="$1"

# Define the output video file name (you can change this)
OUTPUT_VIDEO="output_video.mp4"

# Define the resolution for the full-screen video
WIDTH=1920
HEIGHT=1080

# Convert the image to a 5-second full-screen video
ffmpeg -loop 1 -framerate 25 -t 3 -i "$INPUT_IMAGE" -vf "scale=$WIDTH:$HEIGHT" -c:v libx264 -pix_fmt yuv420p "$OUTPUT_VIDEO"

echo "Video created: $OUTPUT_VIDEO"
