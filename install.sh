#!/bin/bash
set -e

echo "Setting up dotfiles on new server..."

# Set password for ubuntu user (only on Ubuntu systems)
if command -v apt &> /dev/null && id -u ubuntu &> /dev/null; then
  echo "Setting password for ubuntu user..."
  sudo passwd ubuntu
fi

# Update package lists once at the beginning (for Debian/Ubuntu)
if command -v apt &> /dev/null; then
  echo "Updating package lists..."
  sudo apt update
fi

# Install git (required for cloning repos)
if ! command -v git &> /dev/null; then
  echo "Installing git..."
  if command -v apt &> /dev/null; then
    sudo apt install -y git
  elif [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
    brew install git
  fi
else
  echo "git is already installed."
fi

# Configure git user name and email
echo "Configuring git user name and email..."
git config --global user.name "adamsoliev"
git config --global user.email "asoliyev13@gmail.com"

# Install vim (required for vim-plug)
if ! command -v vim &> /dev/null; then
  echo "Installing vim..."
  if command -v apt &> /dev/null; then
    sudo apt install -y vim
  elif [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
    brew install vim
  fi
else
  echo "vim is already installed."
fi

# Ensure core build tools are available on Debian/Ubuntu systems
if command -v apt &> /dev/null; then
  echo "Installing the build-essential package, which includes GCC, G++, and Make..."
  sudo apt install -y build-essential
fi

# Install ripgrep (fast search tool)
if ! command -v rg &> /dev/null; then
  echo "Installing ripgrep..."
  if command -v apt &> /dev/null; then
    sudo apt install -y ripgrep
  elif [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
    brew install ripgrep
  fi
else
  echo "ripgrep is already installed."
fi

# Install clangd and clang-format (C/C++ language server and formatter)
if ! command -v clangd &> /dev/null || ! command -v clang-format &> /dev/null; then
  echo "Installing clangd and clang-format..."
  if command -v apt &> /dev/null; then
    sudo apt install -y clangd clang-format
  elif [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
    brew install llvm
  fi
else
  echo "clangd and clang-format are already installed."
fi

# Check and install zsh if it's not present
if ! command -v zsh &> /dev/null; then
  echo "Zsh not found, installing now..."
  if command -v apt &> /dev/null; then
    sudo apt install -y zsh
  elif [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
    brew install zsh
  fi
else
  echo "zsh is already installed."
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
  sed -i '' 's/^ZSH_THEME=".*"/ZSH_THEME="apple"/' ~/.zshrc
else
  # Linux (GNU sed)
  sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="apple"/' ~/.zshrc
fi

# Switch to zsh (this will change the default shell for subsequent logins)
if [ "$SHELL" != "$(command -v zsh)" ]; then
  echo "Switching default shell to zsh..."
  chsh -s "$(command -v zsh)"
fi

echo "Setup complete!"
echo "Please restart your terminal session or run 'exec zsh' to use your new configuration."
