# Directorio home del usuario
USER_DIR=/home/gdonaire

# Usuario
USER=gdonaire

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Para snap
export PATH="$PATH:$HOME/.cargo/bin"
export PATH=$PATH:/snap/bin

# Tema de p10k
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  sudo
  fzf
  aliases
  zsh-autosuggestions
  zsh-syntax-highlighting
  ansible
  colorize
  colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run 'p10k configure' or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=$HOME/.zsh_history

# User configuration
export HOME="${USER_DIR}"
export FZF_BASE="$HOME/.fzf"

# Alias
alias catt='bat'
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
