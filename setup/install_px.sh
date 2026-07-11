# Setup script for dotfiles and required packages when no sudo access.

mv ~/.bashrc ~/.bashrc.bak
mv ~/.gitconfig ~/.gitconfig.bak

# rbw + pinentry: Bitwarden CLI for the Claude Slack-notify hook (conda-forge).
micromamba install -y stow zsh zoxide fzf xclip ripgrep fd-find btop rbw pinentry
curl -fsSL https://claude.ai/install.sh | bash
curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin

cd ~/dotfiles
stow .

zsh

# First login perso
gh auth login
# Then work login
gh auth login

# Bitwarden (rbw). Secret-free config is stowed to ~/.config/rbw/config.json.
# Per-machine, interactive (cannot be committed): device API key + master
# password + 2FA.
rbw register   # paste personal API key client_secret:
               #   Bitwarden web vault -> Account Settings -> Security -> Keys -> View API Key
rbw login
rbw unlock