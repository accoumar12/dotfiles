export PATH="$HOME/tools/nvim/bin:$PATH" 

# For zoxide.
export PATH="$HOME/.local/bin:$PATH"

# Needed to use the latex extension for vscode.
export PATH="/usr/local/texlive/2024/bin/x86_64-linux:$PATH"

# To launch vscode from cli in wsl.
export PATH="/mnt/c/Users/maccou/AppData/Local/Programs/Microsoft VS Code/bin:$PATH"

# For sqlc.
export PATH="/snap/bin:$PATH"

# For uv.
# source "$HOME/.cargo/env"

export POETRY_VIRTUALENVS_IN_PROJECT=true

__conda_setup="$('/home/maccou/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/maccou/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/maccou/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/maccou/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

FNM_PATH="/home/maccou/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/home/maccou/.local/share/fnm:$PATH"
  eval "`fnm env --shell zsh`"
fi
export MANPATH=$HOME/tools/ripgrep/doc/man:$MANPATH
export FPATH=$HOME/tools/ripgrep/complete:$FPATH

export EDITOR=vim

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light MichaelAquilina/zsh-you-should-use
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit snippet OMZ::plugins/vi-mode/vi-mode.plugin.zsh
zinit light kutsan/zsh-system-clipboard

source ~/.config/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
# Does not work
# source ~/.config/.zsh/zsh_vi_search.zsh

# Add in snippets
zinit snippet OMZP::git
# zinit snippet OMZP::sudo
# zinit snippet OMZP::archlinux
# zinit snippet OMZP::aws
# zinit snippet OMZP::kubectl
# zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Avoid redundant generation of zcompdump
autoload -Uz compinit
if [[ ! -f ~/.zcompdump ]]; then
  compinit
else
  compinit -C  # Use the cache without recomputing
fi

zinit cdreplay -q

# Prompt
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey ']' autosuggest-accept
bindkey -v

zle_highlight+=(paste:none)

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
HISTORY_IGNORE="(l|c|cd|gac)*"
setopt extended_history      # Write the history file in the ':start:elapsed;command' format.
setopt inc_append_history    # Write to the history file immediately, not when the shell exits.
setopt share_history         # Share history between all sessions.
setopt hist_ignore_dups      # Do not record an event that was just recorded again.
setopt hist_ignore_all_dups  # Delete an old recorded event if a new event is a duplicate.
setopt hist_ignore_space     # Do not record an event starting with a space.
setopt hist_save_no_dups     # Do not write a duplicate event to the history file.
setopt hist_verify           # Do not execute immediately upon history expansion.
setopt append_history        # append to history file (Default)
setopt hist_no_store         # Don't store history commands
setopt hist_reduce_blanks    # Remove superfluous blanks from each command line being added to the history.
HIST_STAMPS="yyyy-mm-dd"

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

source ~/.zsh_aliases

# Enable extended globbing
setopt extendedglob

# Shell integrations
eval "$(zoxide init --cmd cd zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(uv generate-shell-completion zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh) # Make sure to have a recent fzf version
source <(just --completions zsh)
eval "$(direnv hook zsh)" 


# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE='/home/maccou/.local/bin/micromamba';
export MAMBA_ROOT_PREFIX='/home/maccou/micromamba';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

# Bitwarden completions
eval "$(bw completion --shell zsh); compdef _bw bw;"
