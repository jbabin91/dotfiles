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
export PATH="/usr/local/sbin:$PATH"

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
# Homebrew settings
export HOMEBREW_NO_INSTALL_CLEANUP=TRUE

# exa
alias l="exa -al --color=always --group-directories-first --git --icons"
alias ls="exa -al --color=always --group-directories-first --git --icons" # my preferred listing
alias la="exa -a --color=always --group-directories-first --git --icons"  # all files and dirs
alias ll="exa -l --color=always --group-directories-first --git --icons"  # long format
alias t="exa -aT --color=always --group-directories-first --git --icons" # tree listing
alias l.='exa -a | egrep "^\."'

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# General UNIX
alias c="clear"
alias cp="cp -iv"
alias df="df -h"                          # human-readable sizes
alias du="du -d 1 -h"
alias duf="du -sh *"
alias mkdir="mkdir -pv"
alias mv="mv -iv"
alias path="echo -e ${PATH//:/\\n}"
alias pi="ping -Anc 5 1.1.1.1"
alias reload!='exec "$SHELL" -l'
alias zr="source ~/.zshrc"
alias rm="rm -iv"
alias srm="srm -iv"

# adding flags
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
#alias glnext="git log --oneline $(git describe --tags --abbrev=0 @^)..@"
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

# LazyGit
alias lg="lazygit"

# switch between shells
# I do not recommend switching default SHELL from bash.
alias tobash="chsh -s $(which bash) && echo 'Now log out.'"
alias tozsh="chsh -s /bin/zsh && echo 'Now log out.'"
alias tofish="chsh -s $(which fish) && echo 'Now log out.'"

# dotfiles
alias edit="e ~/.dotfiles"
alias .f="cd ~/.dotfiles"
alias .dot="cd ~/.dotfiles && nvim ."
alias .fish="cd ~/.dotfiles/config/fish && nvim config.fish"
alias .kitty="cd ~/.dotfiles/config/kitty && nvim kitty.conf"
alias .nvim="cd ~/.dotfiles/config/nvim && nvim ."
alias .zsh="cd ~/.dotfiles/config/zsh && nvim .zshrc"

# Git/Work directories
alias .g="cd ~/code/github/jbabin91"
alias .w="cd ~/code/work"

# Minikube
alias kubectl="minikube kubectl --"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh" # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

# iTerm integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# zoxide
eval "$(zoxide init zsh)"

eval "$(starship init zsh)"

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

export PNPM_HOME="/Users/jacebabin/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
