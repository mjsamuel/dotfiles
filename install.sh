#!/bin/sh

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle
brew tap homebrew/bundle
brew bundle

# Set default MySQL root password and auth type.
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

# Install Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from our dotfiles
rm -rf $HOME/.zshrc
ln -s $HOME/Developer/dotfiles/shell/.zshrc $HOME/.zshrc

# Symlinks zsh functions, paths and theme from our dotfiles
ln -s $HOME/Developer/dotfiles/shell/functions.zsh $HOME/.oh-my-zsh/custom/functions.zsh
ln -s $HOME/Developer/dotfiles/shell/path.zsh $HOME/.oh-my-zsh/custom/path.zsh
ln -s $HOME/Developer/dotfiles/shell/theme.zsh-theme $HOME/.oh-my-zsh/custom/themes/theme.zsh-theme

# Removes deafult neofetch config file and symlinks config file from our dotfiles
rm -rf iHOME/.config/neofetch/config.conf
ln -s $HOME/Developer/dotfiles/.neofetch.conf $HOME/.config/neofetch/config.conf
