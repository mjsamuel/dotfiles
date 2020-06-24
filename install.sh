# Install Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the Developer/dotfiles
rm -rf $HOME/.zshrc
ln -s $HOME/Developer/dotfiles/.zshrc $HOME/.zshrc

# Symlink functions and paths
ln -s $HOME/Developer/dotfiles/functions.zsh $HOME/.oh-my-zsh/custom
ln -s $HOME/Developer/dotfiles/path.zsh $HOME/.oh-my-zsh/custom
