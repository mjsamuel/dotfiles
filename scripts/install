DOTFILES_DIR="$HOME/Developer/dotfiles"
mkdir -p "$HOME/Developer"
git clone "git@github.com:mjsamuel/dotfiles.git" "$DOTFILES_DIR"

# Remove .zprofile from home (if it exists) and symlink new one
rm -f "$HOME/.zprofile"
ln -s "$DOTFILES_DIR/config/zsh/.zprofile" "$HOME"
. "$HOME/.zprofile" # source zprofile
mkdir -p "$HOME/.cache/zsh"

# Symlinks
ln -s "$DOTFILES_DIR/config" "$HOME/.config"

# Disable ssh password authentication
sudo cp "$DOTFILES_DIR/other/ssh.conf" "/etc/ssh/sshd_config.d/"

# Install Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
# Update Homebrew recipes and install dependencies using bundle
brew update
BUNDLE_FAILED=false
brew tap homebrew/bundle
brew bundle --file "$DOTFILES_DIR/Brewfile" || BUNDLE_FAILED=true

# Install tt (typing test)
sudo mkdir -p "/usr/local/bin"
git clone "https://github.com/lemnos/tt.git" "$HOME/Developer/tt"
cd "$HOME/Developer/tt" && make && sudo make install
rm -rf "$HOME/Developer/tt"

# Wezterm undercurl support
tempfile=$(mktemp) \
  && curl -o "$tempfile" https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo \
  && tic -x -o ~/.terminfo "$tempfile" \
  && rm "$tempfile"

neofetch
echo "Install complete! Please restart your terminal."
[ "$BUNDLE_FAILED" = true ] && echo "- Some packages failed to install. Run 'brew bundle --file $DOTFILES_DIR/Brewfile' manually."
