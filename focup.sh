#!/bin/zsh

ffmpeg -f avfoundation \
       -r 30 \
       -pix_fmt uyvy422 \
       -i "Capture screen 0" \
       -f avfoundation \
       -video_size 1280x720 \
       -framerate 60 \
       -pix_fmt uyvy422 \
       -i "C922 Pro Stream Webcam" \
       -filter_complex "[1:v]vflip, hflip[tmp]; [0:v][tmp]overlay=x=0:y=0, setpts=PTS/5.0" \
       -preset ultrafast \
       -c:v libx264 \
       -f mp4 \
       -loglevel warning \
       merged-$1.mp4
