# Matt's Dotfiles

## Installation

### Perquisites
macOS:
```sh
xcode-select --install
```

Debian based:
```sh
apt update
apt install curl git sudo
```
**Note:** For Raspberry Pi OS, ensure a locale is set (`sudo raspi-config`)

### Bootstrap
Clone the repo and run the bootstrap script:
```sh
git clone https://github.com/mjsamuel/dotfiles.git $HOME/Developer/dotfiles
$HOME/Developer/dotfiles/bootstrap
```

Once completed, switch the remote url from HTTPS to SSH:
```sh
git remote set-url origin git@github.com:mjsamuel/dotfiles.git
```

## Testing (with docker)
To make sure the bootstrap process works as expected after any major changes,
create and run a docker image (that goes through the bootstrap process) with
the following commands:
```sh
docker build . -t dotfiles -f docker/Dockerfile.debian
docker run --rm -it dotfiles
```
