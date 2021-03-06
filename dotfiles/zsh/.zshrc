#!/bin/zsh
#zmodload zsh/zprof

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="false"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy/mm/dd"
HIST_IGNORE_SPACE="true"

# How many lines of history to keep in memory
HISTSIZE=5000

# Where to save history to disk
HISTFILE=~/.zsh_history

# Number of history entries to save to disk
SAVEHIST=5000

# Erase duplicates in the history file
HISTDUP=erase

# Append history to the history file (no overwriting)
setopt appendhistory

# Share history across terminals
setopt sharehistory

# Immediately append to the history file, not just when a term is killed
setopt incappendhistory

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  alias-finder
  copydir
  copyfile
  docker
  docker-compose
  dotnet
  encode64
  extract
  flutter
  gitfast
  gitignore
  golang
  jsontools
  npm
  nvm
  osx
  pip
  pyenv
  rbenv
  tmux
  urltools
  web-search
  yarn
  z
  zsh-dircolors-solarized
  ssh-agent
)

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

ulimit -n 10000
zstyle :omz:plugins:ssh-agent agent-forwarding on

# Enable command caching and force prefix matching
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# User configuration
source $HOME/.shell_env

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

#zprof
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Apply starship theme
# eval "$(starship init zsh)"
