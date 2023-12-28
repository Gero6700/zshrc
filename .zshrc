#Directorio home del usuario
USER_DIR=/home/gd2k

#Usuario
USER=gd2k

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

#Tema de p10k
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  sudo
  aliases
  fzf
  zsh-autosuggestions
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
export FZF_BASE="$HOME/.fzf"  # Configura la variable FZF_BASE

#Alias
alias catt='bat'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source ${USER_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme