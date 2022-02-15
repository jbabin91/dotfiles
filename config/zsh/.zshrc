export LC_ALL="en_US.UTF-8"
export EDITOR=nvim

# Path to your own oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# themes ---------------------------------------------------------------
ZSH_THEME="robbyrussell"

# plugins ---------------------------------------------------------------
plugins=(
  vi-mode
  git
  sudo
  yarn
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$ANDROID_HOME/cmdline-tools/tools/bin/:$PATH
export PATH=$ANDROID_HOME/emulator/:$PATH
export PATH=$ANDROID_HOME/platform-tools/:$PATH

jdk() {
  version=$1
  export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
  java -version
}

# Kitty ------------------------------------------------------------------------
autoload -Uz compinit
compinit
# Completion for kitty
kitty + complete setup zsh | source /dev/stdin

# Aliases --------------------------------------------------------------
alias c="clear"

# root privileges
alias doas="doas --"

# navigation
alias ..="cd .."
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."
alias .5="cd ../../../../.."

# vim and emacs
alias vim="nvim"
alias v="nvim"
alias e="code"
alias em="/usr/bin/emacs -nw"
alias emacs="emacsclient -c -a 'emacs'"
alias doomsync="~/.emacs.d/bin/doom sync"
alias doomdoctor="~/.emacs.d/bin/doom doctor"
alias doomupgrade="~/.emacs.d/bin/doom upgrade"
alias doompurge="~/.emacs.d/bin/doom purge"

# Brew
alias bu="brew update"
alias buu="brew upgrade"
alias bc="brew cleanup"
alias bd="brew doctor"
alias ud="brew update && brew upgrade && brew cleanup"

# exa
alias l="exa -al --color=always --group-directories-first --git --icons"
alias ls="exa -al --color=always --group-directories-first --git --icons" # my preferred listing
alias la="exa -a --color=always --group-directories-first --git --icons"  # all files and dirs
alias ll="exa -l --color=always --group-directories-first --git --icons"  # long format
alias lt="exa -aT --color=always --group-directories-first --git --icons" # tree listing
alias l.='exa -a | egrep "^\."'

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

# adding flags
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias lynx='lynx -cfg=~/.lynx/lynx.cfg -lss=~/.lynx/lynx.lss -vikeys'
alias vifm='./.config/vifm/scripts/vifmrun'
alias ncmpcpp='ncmpcpp ncmpcpp_directory=$HOME/.config/ncmpcpp/'
alias mocp='mocp -M "$XDG_CONFIG_HOME"/moc -O MOCDir="$XDG_CONFIG_HOME"/moc'

# ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# git
alias g="git"
alias gs="git status -sb"
alias gd="git diff"
alias gdc="git diff --cached"
alias gdca="git diff --cached --all"
alias gdcaa="git diff --cached --all --stat"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit -s"
alias gcm="git commit -s -m"
alias gcam="git commit -s -a -m"
alias glg="git log --graph --decorate --oneline --abbrev-commit"
alias glga="glg --all"
alias glnext="git log --oneline $(git describe --tags --abbrev=0 @^)..@"
alias gp="git push origin HEAD"
alias gpa="git push origin --all"
alias gpr="gp && git pr"
alias addup="git add -u"
alias addall="git add ."
alias branch="git branch"
alias checkout="git checkout"
alias clone="git clone"
alias commit="git commit -m"
alias fetch="git fetch"
alias pull="git pull origin"
alias push="git push origin"
alias tag="git tag"
alias newtag="git tag -a"

# switch between shells
# I do not recommend switching default SHELL from bash.
alias tobash="chsh -s $(which bash) && echo 'Now log out.'"
alias tozsh="chsh -s /bin/zsh && echo 'Now log out.'"
alias tofish="chsh -s $(which fish) && echo 'Now log out.'"

# dotfiles
alias .f="cd ~/.dotfiles"
alias .dot="cd ~/.dotfiles && nvim ."
alias .fish="cd ~/.dotfiles/config/fish && nvim config.fish"
alias .kitty="cd ~/.dotfiles/config/kitty && nvim kitty.conf"
alias .nvim="cd ~/.dotfiles/config/nvim && nvim ."
alias .zsh="cd ~/.dotfiles/config/zsh && nvim .zshrc"

# Git/Work directories
alias .g="cd ~/code/github/jbabin91"
alias .w="cd ~/code/work"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

eval "$(starship init zsh)"
