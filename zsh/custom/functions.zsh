# Create a new directory and enter it
mkd() {
    mkdir -p "$@" && cd "$_";
}

g() {
  if [[ $# > 0 ]]; then
    git $@
  else
    git status
  fi
}
