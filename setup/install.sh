#!/usr/bin/env bash
# filepath: /home/maccou/dotfiles/install.sh

set -e  # Exit immediately if a command exits with non-zero status

echo "====== Starting dotfiles installation ======"

# Detect package manager
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    PKG_UPDATE="sudo apt update"
    PKG_INSTALL="sudo apt install -y"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    PKG_UPDATE=""  # DNF doesn't require separate update
    PKG_INSTALL="sudo dnf install -y"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    PKG_UPDATE=""  # We're using -Sy in install which updates
    PKG_INSTALL="sudo pacman -Sy --noconfirm"
else
    echo "Unsupported package manager. Please install the required packages manually."
    exit 1
fi

# Install git and stow if not already installed
echo "Installing git and stow..."
if [ -n "$PKG_UPDATE" ]; then
    $PKG_UPDATE
fi
$PKG_INSTALL git stow curl

# Clone dotfiles repository if not already cloned
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dotfiles repository..."
    git clone git@github.com:accoumar12/dotfiles.git "$DOTFILES_DIR"
else
    echo "Dotfiles repository already exists at $DOTFILES_DIR"
    echo "Pulling latest changes..."
    cd "$DOTFILES_DIR" && git pull
fi

# Install required packages
echo "Installing zsh, fzf, and other required packages..."
if [ "$PKG_MANAGER" = "apt" ]; then
    $PKG_INSTALL zsh fzf python3 python3-pip
elif [ "$PKG_MANAGER" = "dnf" ]; then
    $PKG_INSTALL zsh fzf python3 python3-pip
elif [ "$PKG_MANAGER" = "pacman" ]; then
    $PKG_INSTALL zsh fzf python python-pip
fi

# Install starship
echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install uv (Python package installer)
echo "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install just
echo "Installing just..."
$PKG_INSTALL just

echo "Installing micro-mamba..."
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)

echo "Installing nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Apply dotfiles using stow
echo "Setting up dotfiles with stow..."
cd "$DOTFILES_DIR"
stow .

# Set zsh as default shell
echo "Setting zsh as default shell..."
chsh -s $(which zsh)

echo "====== Installation complete! ======"
echo "Please log out and log back in to complete the setup."
echo "Your dotfiles have been installed and configured."
