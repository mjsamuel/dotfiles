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

edf() {
    subl ~/Developer/dotfiles/shell/functions.zsh
}

ai() {
    cd ~/School/ai/Homework/p2-multiagent-thinky
    subl .
    open http://ai.berkeley.edu/multiagent.html
}

hb-sync() {
    cd $HOME/Developer/homebridge/Homebridge-MagicHome-Sync
    source ./host/venv/bin/activate
}

ipse() {
  cd ~/School/ipse/Assignment\ 1/Bonfire
  open Bonfire.xcodeproj
  open ../2020_S2_A1_iphone.pdf
  open https://rmit.instructure.com/courses/75755/assignments/481832
}

site() {
    cd $HOME/Developer/mjsamuel.github.io
    subl .
    open http://localhost:4000
    bundle exec jekyll serve --watch --livereload --host 0.0.0.0
}
