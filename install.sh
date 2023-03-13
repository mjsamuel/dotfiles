set -e

DOTFILES_DIR="$HOME/Developer/dotfiles"
BUNDLE_FAILED=false

sudo mkdir -p "/usr/local/bin"
mkdir -p "$HOME/Developer"

# Install Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Clone dotfiles repo and sourch profile
git clone "https://github.com/mjsamuel/dotfiles.git" "$DOTFILES_DIR"
. "${DOTFILES_DIR}/config/zsh/.zprofile"

# Update Homebrew recipes and install dependencies using bundle
brew update
brew tap homebrew/bundle
brew bundle --file "$DOTFILES_DIR/Brewfile" || BUNDLE_FAILED=true

# Remove .zprofile from home (if it exists) and symlink new one
rm -f "$HOME/.zprofile"
ln -s "$DOTFILES_DIR/config/zsh/.zprofile" "$HOME"

# Symlink config files
ln -s "$DOTFILES_DIR/config" "$HOME/.config"

# Install tt (typing test)
git clone "https://github.com/lemnos/tt.git" "$HOME/Developer/tt"
cd "$HOME/Developer/tt" && make && sudo make install

# Dark mode notify
# git clone "https://github.com/bouk/dark-mode-notify.git" "$HOME/Developer/dark-mode-notify" 
# cd "$HOME/Developer/dark-mode-notify" && sudo make install
# cp "$DOTFILES_DIR/other/scripts/com.matthewsamuel.dark-mode-notify.plist" "$HOME/Library/LaunchAgents/"
# sudo launchctl load -w "$HOME/Library/LaunchAgents/com.matthewsamuel.dark-mode-notify.plist"
sudo ln -s "$DOTFILES_DIR/scripts/changecolors" "/usr/local/bin/"

# Disable ssh password authentication
sudo cp "$DOTFILES_DIR/other/ssh.conf" "/etc/ssh/sshd_config.d/"

# cleanup
rm -rf "$HOME/Developer/tt"

neofetch
echo "Install complete! Please restart your terminal."
[ "$BUNDLE_FAILED" = true ] && echo "INFO: Some packages failed to install. Run 'brew bundle --file $DOTFILES_DIR/Brewfile' manually."
