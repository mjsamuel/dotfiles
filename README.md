# Matt's Dotfiles

<img src="/images/screenshot.png"/>

A collection of dotfiles that I use for customising my macOS machine.

The provided `install.sh` script installs and sets up some of the applications and tools I use on a day-to-day basis for software development.

I prefer to store my dotfiles (as well as all my other projects) in a folder named 'Developer' and so in order for the install script to run properly this repository should be cloned into `~/Developer`.

## Installation

1. Update macOS to the latest version with the App Store.
2. Install Xcode from the App Store, open it and accept the license agreement.
3. Install macOS Command Line Tools by running:
   ```
   xcode-select --install
   ```
4. Install [zsh](https://github.com/robbyrussell/oh-my-zsh#getting-started).
5. Generate ssh keys and associate it with Github:
   ```
   ssh-keygen -t ed25519
   ```
6. Clone this repo into `~/Deveoper` with the following command:
   ```
   git clone https://github.com/mjsamuel/dotfiles.git $HOME/Developer
   ```
7. Run the install script with:
   ```
   ./install.sh
   ```

## Post-install Tasks

### Setting up iTerm2

1. Open `~/Developer/iterm/mirage dark.itermcolors` to import the colour preset.
2. Open iTerm2.
3. Select iTerm2 > Preferences.
4. Under the General tab, check the box labeled "Load preferences from a custom folder or URL:"
5. Click on "Browse" and point it to `~/Developer/dotfiles/iterm/com.googlecode.iterm2.plist`.
6. Restart iTerm2.

### Neovim

1. Open up vim and run the following commands to install all plugins
   ```
   :PlugInstall
   ```

## Thanks to...

- [Mathias Bynens](https://github.com/mathiasbynens) and their [dotfiles repository](https://github.com/mathiasbynens/dotfiles)
- [Dries Vints](https://github.com/driesvints) and their [dotfiles repository](https://github.com/driesvints/dotfiles)
- [Joshua Steele](https://github.com/joshukraine) and their [dotfiles repository](https://github.com/joshukraine/dotfiles#installation)
- [Scott Nesham](https://github.com/sevenfoxes) and their [ghostwheel zsh theme](https://github.com/Powerlevel9k/powerlevel9k/wiki/Show-Off-Your-Config#ghostwheel)
- [Michele Gerarduzzi](https://github.com/michelegera) and their [iTerm colour preset](https://github.com/michelegera/iterm2-ayu-mirage)
