# Create a new directory and enter it
mkd() {
    mkdir -p "$@" && cd "$_";
}

unalias g
g() {
  if [[ $# > 0 ]]; then
    git $@
  else
    git status
  fi
}

#######################################
# Downloads either the audio, video or the thumbnail of a video
# 
# Options:
#   -a Whether to download the audio or not
#   -t Whether to download the thumbnail or not
#   -v Whether to download the video or not
#   -V [resolution] Whether to download a video and the resolution to do it at
# Arguments:
#   URL of the video you want to download specific features of
# Outputs:
#   Writes the file to the current directory
# Examples:
#   dl -atv https://www.youtube.com/watch?v=dQw4w9WgXcQ
#   dl -V 480 https://www.youtube.com/watch?v=dQw4w9WgXcQ
#   dl -V 720 https://www.youtube.com/watch?v=dQw4w9WgXcQ
#######################################
dl() {
  COLOR_GREEN="\u001b[32m"
  COLOR_RED="\u001b[31m"
  COLOUR_RESET="\u001b[0m"

  audio_flag=false
  thumbnail_flag=false
  video_flag=false
  video_resolution=

  while getopts atvV: option; do
    case $option in
      a) audio_flag=true;;
      t) thumbnail_flag=true;;
      v) video_flag=true;;
      V) video_resolution=$OPTARG;;
      \?) return;;
    esac
  done

  shift $((OPTIND - 1))
  url="$@"

  # Exiting if a URL isn't provided
  if [[ -z $url ]]; then
    echo "${COLOR_RED}ERROR${COLOUR_RESET}: A URL must be specified"
    return
  fi

  # Extracting and downloading the mp3 from the video
  if [[ $audio_flag = true ]]; then
    echo "${COLOR_GREEN}DOWNLOADING AUDIO${COLOUR_RESET}"
    youtube-dl --extract-audio --audio-format mp3 "$url"
  fi

  # Downloading the thumbnail from the video
  if [[ $thumbnail_flag = true ]]; then
    echo "${COLOR_GREEN}DOWNLOADING THUMBNAIL${COLOUR_RESET}"
    youtube-dl --write-thumbnail --skip-download "$url"
  fi 

  # Downloading the video at the specified resolution or lower if not available
  if [[ -n $video_resolution ]]; then
    echo "${COLOR_GREEN}DOWNLOADING VIDEO${COLOUR_RESET}"
    youtube-dl -f \
      'bestvideo[height<='"$video_resolution"']+bestaudio/best[height<='"$video_resolution"']' \
      "$url"
  # Downloading the video at the best quality available
  elif [[ $video_flag = true ]]; then
    echo "${COLOR_GREEN}DOWNLOADING VIDEO${COLOUR_RESET}"
    youtube-dl "$url"
  fi
}

# Quickly clone one of my repos
clone() {
    git clone "git@github.com:mjsamuel/$1.git"
}

