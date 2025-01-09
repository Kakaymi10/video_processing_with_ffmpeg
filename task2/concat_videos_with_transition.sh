#!/bin/bash

ffmpeg -i output_video.mp4 -c copy intermediate1.ts
ffmpeg -i office_tour.mp4 -c copy intermediate2.ts
ffmpeg -i "concat:intermediate1.ts|intermediate2.ts" -c copy output.mp4