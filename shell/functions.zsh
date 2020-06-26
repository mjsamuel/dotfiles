# Create a new directory and enter it
function mkd() {
    mkdir -p "$@" && cd "$_";
}

# Takes either one or two arguments to download videos, thumnails or audio using
# youtube-dl.
#
# $1 - Specify if downloading the audio of a video (`a`), it's thumbnail ('t')
#      or the video resolution (any integer). If none of these are specified then
#      the argument is used as a url.
# $2 - Video url if $1 is specified
#
# Examples
#     dl https://www.youtube.com/watch?v=dQw4w9WgXcQ
#     dl 480 https://www.youtube.com/watch?v=dQw4w9WgXcQ
#     dl 720 https://www.youtube.com/watch?v=dQw4w9WgXcQ
#     dl t https://www.youtube.com/watch?v=dQw4w9WgXcQ
#     dl a https://www.youtube.com/watch?v=dQw4w9WgXcQ
dl() {
    if [[ "$1" =~ ^-?[0-9]+$ ]]
    then
        # Downloads a video at the specified resolution or lower if not available
        youtube-dl -f 'bestvideo[height<='"$1"']+bestaudio/best[height<='"$1"']' "$2"
    elif [ "$1" = "a" ]
    then
        # Downloads only the audio of a video as an .mp3
        youtube-dl --extract-audio --audio-format mp3 "$2"
    elif [ "$1" = "t" ]
    then
        # Downloads the thumbnail of a video
        youtube-dl --write-thumbnail --skip-download "$2"
    else
        # Downloads a video at the best quality available
        youtube-dl "$1"
    fi
}
