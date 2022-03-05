#!/bin/sh

echo "Setting up your pi..."

# install packages
# NOTE: will need to build mosh and neovim from source seperately
apt install \
    tmux \
    exa \
    fzf \
    git \
    bat \
    neofetch

ln -s /usr/bin/batcat /usr/bin/bat

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# Configuring git
git config --global user.name "mjsamuel"
git config --global user.email "matthew.samuel@outlook.com.au"

# Remove .zshrc from $HOME (if it exists) and symlinks the .zshrc file from our dotfiles
rm -rf $HOME/.zshrc
ln -s $HOME/Developer/dotfiles/zsh/.zshrc $HOME/.zshrc

# Symlinks zsh functions, paths and theme from our dotfiles
ln -s $HOME/Developer/dotfiles/zsh/functions.zsh $HOME/.oh-my-zsh/custom/functions.zsh
ln -s $HOME/Developer/dotfiles/zsh/aliases.zsh $HOME/.oh-my-zsh/custom/aliases.zsh
ln -s $HOME/Developer/dotfiles/zsh/path.zsh $HOME/.oh-my-zsh/custom/path.zsh
ln -s $HOME/Developer/dotfiles/zsh/theme.zsh-theme $HOME/.oh-my-zsh/custom/themes/theme.zsh-theme

# Symlink tmux config file
ln -s $HOME/Developer/dotfiles/tmux/.tmux.conf $HOME/

# Symlink vimrc
ln -s $HOME/Developer/dotfiles/nvim $HOME/.config/
# Install vim plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Removes deafult neofetch config file and symlinks config file from our dotfiles
neofetch >/dev/null 2>&1
rm -rf $HOME/.config/neofetch/config.conf
ln -s $HOME/Developer/dotfiles/other/neofetch.conf $HOME/.config/neofetch/config.conf

neofetch
echo "Install complete"
