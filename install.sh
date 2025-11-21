#!/bin/bash
set -e

echo "Setting up dotfiles on new server..."

# Ensure core build tools are available on Debian/Ubuntu systems
if command -v apt &> /dev/null; then
  echo "Installing the build-essential package, which includes GCC, G++, and Make..."
  sudo apt update
  sudo apt install build-essential
fi

# Check and install zsh if it's not present
if ! command -v zsh &> /dev/null; then
  echo "Zsh not found, installing now..."
  sudo apt-get update
  sudo apt-get install -y zsh
fi

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  # Use --unattended to avoid the 'exec zsh' behavior
  # This makes the script continue after installation
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh is already installed."
fi

# Install vim-plug (Vim plugin manager)
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  echo "Installing vim-plug..."
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "vim-plug is already installed."
fi

# Copy dotfiles from repo to home
echo "Installing dotfiles..."
cp .zshrc ~/
cp .vimrc ~/

# Ensure ZSH theme is set after copying your dotfiles
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS (BSD sed)
  sed -i '' 's/^ZSH_THEME=".*"/ZSH_THEME="evan"/' ~/.zshrc
else
  # Linux (GNU sed)
  sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="evan"/' ~/.zshrc
fi

# Switch to zsh (this will change the default shell for subsequent logins)
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Switching default shell to zsh..."
  chsh -s $(which zsh)
fi

echo "Setup complete!"
echo "Please restart your terminal session or run 'exec zsh' to use your new configuration."
