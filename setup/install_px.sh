# Setup script for dotfiles and required packages when no sudo access.

mv ~/.bashrc ~/.bashrc.bak
mv ~/.gitconfig ~/.gitconfig.bak

micromamba install -y stow zsh zoxide fzf xclip ripgrep fd-find btop
curl -fsSL https://claude.ai/install.sh | bash
curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin

cd ~/dotfiles
stow .

zsh

# First login perso 
gh auth login
# Then work login
gh auth login