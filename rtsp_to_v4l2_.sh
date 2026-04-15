#!/usr/bin/env bash
# Expose the HikVision PTZ RTSP stream as a V4L2 virtual camera at
# /dev/video10 so that any program expecting a regular webcam (OpenCV,
# Zoom, OBS, ...) can consume it. See ToDo.md (2026-04-15) and the
# accompanying GitHub issue for the rationale.
#
# Usage:
#   ./rtsp_to_v4l2.sh setup    # install deps and load v4l2loopback
#   ./rtsp_to_v4l2.sh stream   # ffmpeg pipe RTSP -> /dev/video10
#   ./rtsp_to_v4l2.sh          # equivalent to: setup && stream

set -euo pipefail

# Camera credentials and stream path are hardcoded to match the rest of
# this repo (see CLAUDE.md "Purpose").
# "rtsp://admin:peal2024@192.168.1.219:554/ISAPI/streaming/channels/02"
# "rtsp://admin:peal2024@192.168.1.220:554/ISAPI/streaming/channels/02"
rtsp_url="rtsp://admin:peal2024@192.168.1.218:554/ISAPI/streaming/channels/02"
video_nr=10
card_label="HikVision PTZ"
device="/dev/video${video_nr}"

setup_loopback() {
    apt-get update
    apt-get install -y \
        v4l2loopback-dkms \
        v4l2loopback-utils \
        ffmpeg

    # Reload only if the device is missing, to avoid kicking out any
    # currently-attached consumer.
    if [ ! -e "${device}" ]; then
        modprobe -r v4l2loopback || true
        modprobe v4l2loopback \
            devices=1 \
            video_nr="${video_nr}" \
            card_label="${card_label}" \
            exclusive_caps=1
    fi

    ls -l "${device}"
}

stream_rtsp() {
    # -rtsp_transport tcp: HikVision RTSP drops UDP packets often.
    # rawvideo + yuv420p: v4l2loopback only accepts uncompressed frames.
    ffmpeg -rtsp_transport tcp \
           -i "${rtsp_url}" \
           -f v4l2 \
           -vcodec rawvideo \
           -pix_fmt yuv420p \
           "${device}"
}

case "${1:-all}" in
    setup)  setup_loopback ;;
    stream) stream_rtsp ;;
    all)    setup_loopback; stream_rtsp ;;
    *)
        echo "Usage: $0 {setup|stream|all}" >&2
        exit 1
        ;;
esac
