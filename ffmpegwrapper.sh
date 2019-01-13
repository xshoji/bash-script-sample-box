#!/bin/bash

function usage()
{
cat << _EOT_

   ffmpegwrapper   
  ------------------ author: xshoji

  Usage:
    ./$(basename "$0") --videoPath /path/to/originalVideo.avi --audioPath /path/to/talkAudio.wav --delayAudioTime 00:00:10 --output /path/to/output.mp4 [ --volumeRatioVideo 0.2 --volumeRatioAudio 1.0 --videoLength 10 --brightness 0.1 ]

  Description:
    This is ffmpegwrapper

  Required parameters:
    --videoPath,-v /path/to/originalVideo.avi : A path of original video.
    --audioPath,-a /path/to/talkAudio.wav : A path of talk audio.
    --delayAudioTime,-d 00:00:10 : A delay time string for audio.
    --output,-o /path/to/output.mp4 : A path of output video.
 
  Optional parameters:
    --volumeRatioVideo 0.2 : A ratio of video volume. [ default: 0.2 ]
    --volumeRatioAudio 1.0 : A ratio of audio volume. [ default: 1.0 ]
    --videoLength 10 : A second for video length.
    --brightness,-b 0.1 : A brightness of video. [ default: 0.0 ]
    --debug : Enable debug mode

_EOT_
exit 1
}




#------------------------------------------
# Preparation
#------------------------------------------
set -eu

# Parse parameters
for ARG in "$@"
do
    SHIFT="true"
    [ "${ARG}" == "--debug" ] && { shift 1; set -eux; SHIFT="false"; }
    ([ "${ARG}" == "--help" ] || [ "${ARG}" == "-h" ]) && { shift 1; HELP="true"; SHIFT="false"; }
    ([ "${ARG}" == "--videoPath" ] || [ "${ARG}" == "-v" ]) && { shift 1; VIDEO_PATH="${1}"; SHIFT="false"; }
    ([ "${ARG}" == "--audioPath" ] || [ "${ARG}" == "-a" ]) && { shift 1; AUDIO_PATH="${1}"; SHIFT="false"; }
    ([ "${ARG}" == "--delayAudioTime" ] || [ "${ARG}" == "-d" ]) && { shift 1; DELAY_AUDIO_TIME="${1}"; SHIFT="false"; }
    ([ "${ARG}" == "--output" ] || [ "${ARG}" == "-o" ]) && { shift 1; OUTPUT="${1}"; SHIFT="false"; }
    [ "${ARG}" == "--volumeRatioVideo" ] && { shift 1; VOLUME_RATIO_VIDEO="${1}"; SHIFT="false"; }
    [ "${ARG}" == "--volumeRatioAudio" ] && { shift 1; VOLUME_RATIO_AUDIO="${1}"; SHIFT="false"; }
    [ "${ARG}" == "--videoLength" ] && { shift 1; VIDEO_LENGTH="${1}"; SHIFT="false"; }
    ([ "${ARG}" == "--brightness" ] || [ "${ARG}" == "-b" ]) && { shift 1; BRIGHTNESS="${1}"; SHIFT="false"; }
    ([ "${SHIFT}" == "true" ] && [ "$#" -gt 0 ]) && { shift 1; }
done
[ ! -z "${HELP+x}" ] && { usage; exit 0; }
# Check required parameters
[ -z "${VIDEO_PATH+x}" ] && { echo "[!] --videoPath is required. "; INVALID_STATE="true"; }
[ -z "${AUDIO_PATH+x}" ] && { echo "[!] --audioPath is required. "; INVALID_STATE="true"; }
[ -z "${DELAY_AUDIO_TIME+x}" ] && { echo "[!] --delayAudioTime is required. "; INVALID_STATE="true"; }
[ -z "${OUTPUT+x}" ] && { echo "[!] --output is required. "; INVALID_STATE="true"; }
# Check invalid state and display usage
[ ! -z "${INVALID_STATE+x}" ] && { usage; exit 1; }
# Initialize optional variables
[ -z "${VOLUME_RATIO_VIDEO+x}" ] && { VOLUME_RATIO_VIDEO=""; }
[ -z "${VOLUME_RATIO_AUDIO+x}" ] && { VOLUME_RATIO_AUDIO=""; }
[ -z "${VIDEO_LENGTH+x}" ] && { VIDEO_LENGTH=""; }
[ -z "${BRIGHTNESS+x}" ] && { BRIGHTNESS=""; }



#------------------------------------------
# Main
#------------------------------------------

cat << __EOT__

[ Required parameters ]
videoPath: ${VIDEO_PATH}
audioPath: ${AUDIO_PATH}
delayAudioTime: ${DELAY_AUDIO_TIME}
output: ${OUTPUT}

[ Optional parameters ]
volumeRatioVideo: ${VOLUME_RATIO_VIDEO}
volumeRatioAudio: ${VOLUME_RATIO_AUDIO}
videoLength: ${VIDEO_LENGTH}
brightness: ${BRIGHTNESS}

__EOT__

# Define temp files
TMP_VIDEO_AUDIO_PATH="/tmp/temp.${BASH_SOURCE:-$0}_video_audio.mp3"
TMP_AUDIO_AUDIO_PATH="/tmp/temp.${BASH_SOURCE:-$0}_audio_audio.mp3"
TMP_MIXED_AUDIO_PATH="/tmp/temp.${BASH_SOURCE:-$0}_video_audio_mix_audio.mp3"
trap "{ rm -f ${TMP_VIDEO_AUDIO_PATH} ${TMP_AUDIO_AUDIO_PATH} ${TMP_MIXED_AUDIO_PATH}; }" EXIT

# Define default values
if [ "${VOLUME_RATIO_VIDEO}" == "" ];then
  VOLUME_RATIO_VIDEO="0.2"
fi

if [ "${VOLUME_RATIO_AUDIO}" == "" ];then
  VOLUME_RATIO_AUDIO="1.0"
fi

if [ "${BRIGHTNESS}" == "" ];then
  BRIGHTNESS="0.0"
fi

VIDEO_LENGTH_OPTION=""
if [ "${VIDEO_LENGTH}" != "" ]; then
  VIDEO_LENGTH_OPTION="-t ${VIDEO_LENGTH}"
fi

# Extract video audio and adjust volume.
ffmpeg ${VIDEO_LENGTH_OPTION} -i "${VIDEO_PATH}" -af "volume=${VOLUME_RATIO_VIDEO}" "${TMP_VIDEO_AUDIO_PATH}"
# Adjust audio volume.
ffmpeg ${VIDEO_LENGTH_OPTION} -i "${AUDIO_PATH}" -af "volume=${VOLUME_RATIO_AUDIO}" "${TMP_AUDIO_AUDIO_PATH}"
# Mix video audio and talk audio.
ffmpeg ${VIDEO_LENGTH_OPTION} -ss "${DELAY_AUDIO_TIME}" -i "${TMP_AUDIO_AUDIO_PATH}" -i "${TMP_VIDEO_AUDIO_PATH}" -filter_complex "amerge" -c:a libmp3lame -q:a 4 "${TMP_MIXED_AUDIO_PATH}"
# Mix video and mixed audio.
ffmpeg ${VIDEO_LENGTH_OPTION} -i "${VIDEO_PATH}" -i "${TMP_MIXED_AUDIO_PATH}" -vf eq=brightness=${BRIGHTNESS} -map 0:0 -map 1:0 -shortest ${OUTPUT}
