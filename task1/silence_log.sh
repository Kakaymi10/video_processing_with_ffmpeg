#!/bin/bash
ffmpeg -i jumpcut_edits.mp4 -af silencedetect=n=-50dB:d=1 -f null - 2> silence_log.log
