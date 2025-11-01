# Aliases --------------------------------------------------------------
# root privileges
alias doas="doas --"

[[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm-256color ssh"

# navigation
alias ..="cd .."
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."
alias .5="cd ../../../../.."

# vim and emacs
alias vim="nvim"
alias v="nvim"
# alias e="code --profile Personal"
function e() {
  open "$1" -a Visual\ Studio\ Code
}
function ec() {
  open "$1" -a Cursor
}
# alias ie="code-insiders"
function ie() {
  open "${1:-.}" -a "Visual Studio Code - Insiders"
}
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

# eza
alias l="eza -al --color=always --group-directories-first --git --icons"
alias ls="eza -al --color=always --group-directories-first --git --icons" # my preferred listing
alias la="eza -a --color=always --group-directories-first --git --icons"  # all files and dirs
alias ll="eza -l --color=always --group-directories-first --git --icons"  # long format
alias t="eza -aT --color=always --group-directories-first --git --icons"  # tree listing
alias l.='eza -a | egrep "^\."'

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# General UNIX
alias c="clear"
alias cp="cp -iv"
alias df="df -h" # human-readable sizes
alias du="du -d 1 -h"
alias duf="du -sh *"
alias mkdir="mkdir -pv"
alias mv="mv -iv"
alias path='echo -e ${PATH//:/\\n}'
alias pi="ping -Anc 5 1.1.1.1"
alias reload!='exec "$SHELL" -l'
alias zr='exec zsh' # Restart shell cleanly (never use source ~/.zshrc with Zim!)
alias rm="rm -iv"
alias srm="srm -iv"

# adding flag
alias free='free -m' # show sizes in MB
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
alias gcz="czg"
alias gcam="git commit -s -a -m"
alias glg="git log --graph --decorate --oneline --abbrev-commit"
alias glga="glg --all"
# alias glnext="git log --oneline $(git describe --tags --abbrev=0 @^)..@"
alias gp="git push"
alias gpa="git push origin --all"
alias gpr="gp && git pr"
alias addup="git add -u"
alias addall="git add ."
alias branch="git branch"
alias checkout="git checkout"
alias switch="git switch"

# LazyGit
alias lg="lazygit"

# switch between shells
# I do not recommend switching default SHELL from bash.
alias tobash='chsh -s $(which bash) && echo "Now log out."'
alias tozsh='chsh -s /bin/zsh && echo "Now log out."'
alias tofish='chsh -s $(which fish) && echo "Now log out."'

# dotfiles
alias edit="e ~/.dotfiles"
alias .f="cd ~/.dotfiles"
alias .dot="cd ~/.dotfiles && nvim ."
alias .fish="cd ~/.dotfiles/config/fish && nvim config.fish"
alias .kitty="cd ~/.dotfiles/config/kitty && nvim kitty.conf"
alias .nvim="cd ~/.dotfiles/config/nvim && nvim ."
alias .zsh="cd ~/.dotfiles/config/zsh && nvim .zshrc"

# Git/Work directories
alias .g="z jbabin91"

# Minikube
alias kubectl="minikube kubectl --"

# PNPM
alias pn="pnpm"
alias px="pnpx"
