# Create a new directory and enter it
function mkd() {
    mkdir -p "$@" && cd "$_";
}

# 
dl() {
    if [[ "$1" =~ ^-?[0-9]+$ ]]
    then
        youtube-dl -f 'bestvideo[height<='"$1"']+bestaudio/best[height<='"$1"']' "$2"
    elif [ "$1" = "a" ]
    then
        youtube-dl --extract-audio --audio-format mp3 "$2"
    elif [ "$1" = "t" ]
    then
        youtube-dl --write-thumbnail --skip-download "$2"
    else
        youtube-dl "$1"
    fi
}
