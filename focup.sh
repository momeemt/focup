#!/bin/zsh

out=`ffmpeg -f avfoundation \
            -list_devices true \
            -i null |&
            ggrep -Po "((?<=\[)\d+(?=\])|(?<=\[\d\]\s).*$)"`

IFS=$'\n'
array_out=(`echo $out`)

is_searching_video_device=true
video_devices=()
audio_devices=()
for ((i=1; i<=$#array_out; i++)); do
  if [ $(( i%2 )) -eq 0 ]; then
    if "${is_searching_video_device}"; then
      video_devices=($video_devices $array_out[$i])
    else
      audio_devices=($audio_devices $array_out[$i])
    fi
  fi
  if test $i -ne 1 -a $array_out[$i] = "0"; then
    is_searching_video_device=false
  fi
done

main_video_device=""
sub_video_device=""
echo "主画面となる映像入力を選択してください。"
select selected_video_device in $video_devices; do
  main_video_device=$selected_video_device
  break
done

echo "副画面となる映像入力を選択してください。"
select selected_video_device in $video_devices; do
  sub_video_device=$selected_video_device
  break
done

ffmpeg -f avfoundation \
       -r 30 \
       -pix_fmt uyvy422 \
       -i $main_video_device \
       -f avfoundation \
       -video_size 1280x720 \
       -framerate 60 \
       -pix_fmt uyvy422 \
       -i $sub_video_device \
       -filter_complex "[1:v]vflip, hflip[tmp]; [0:v][tmp]overlay=x=0:y=0, setpts=PTS/5.0" \
       -preset ultrafast \
       -c:v libx264 \
       -f mp4 \
       -loglevel warning \
       $1.mp4
