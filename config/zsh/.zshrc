#!/usr/bin/env zsh
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
# =============================================================================
# Zsh Configuration (Antidote)
# =============================================================================

# -----------------------------------------------------------------------------
# Plugin Configuration (must be set BEFORE antidote loads plugins)
# -----------------------------------------------------------------------------
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
export ZSH_HIGHLIGHT_MAXLENGTH=300

# -----------------------------------------------------------------------------
# Completion fpath (must be set BEFORE compinit)
# -----------------------------------------------------------------------------
fpath=("/Users/jacebabin/.oh-my-zsh/custom/completions" "${fpath[@]}")
fpath=("/Users/jacebabin/.docker/completions" "${fpath[@]}")
[ -d "/Users/jacebabin/.bun" ] && fpath=("/Users/jacebabin/.bun" "${fpath[@]}")

# -----------------------------------------------------------------------------
# Ghostty Terminal Handling
# -----------------------------------------------------------------------------
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  export STARSHIP_CACHE="$HOME/.cache/starship"
  export TERM="${TERM:-xterm-ghostty}"
fi

# -----------------------------------------------------------------------------
# FZF Configuration
# -----------------------------------------------------------------------------
export FZF_DEFAULT_COMMAND='rg --files --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# -----------------------------------------------------------------------------
# Antidote Plugin Manager
# -----------------------------------------------------------------------------
source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
antidote load ~/.config/zsh/.zsh_plugins.txt

# -----------------------------------------------------------------------------
# Cached compinit (rebuild once per 24h)
# -----------------------------------------------------------------------------
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# -----------------------------------------------------------------------------
# Tool Inits: Starship, Direnv
# -----------------------------------------------------------------------------
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

# -----------------------------------------------------------------------------
# Tool Inits (Deferred): FZF
# -----------------------------------------------------------------------------
zsh-defer eval "$(fzf --zsh)"

# -----------------------------------------------------------------------------
# Dev Tool Managers: fnm, mise, zoxide
# -----------------------------------------------------------------------------
eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

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
function e() {
  open "$1" -a Visual\ Studio\ Code
}
function ec() {
  open "$1" -a Cursor
}
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
alias ud="brew update && brew upgrade && brew cleanup"

# eza
alias l="eza -al --color=always --group-directories-first --git --icons"
alias ls="eza -al --color=always --group-directories-first --git --icons"
alias la="eza -a --color=always --group-directories-first --git --icons"
alias ll="eza -l --color=always --group-directories-first --git --icons"
alias t="eza -aT --color=always --group-directories-first --git --icons"
alias l.='eza -a | egrep "^\."'

# Colorize grep output
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# General UNIX
alias c="clear"
alias cp="cp -iv"
alias df="df -h"
alias du="du -d 1 -h"
alias duf="du -sh *"
alias mkdir="mkdir -pv"
alias mv="mv -iv"
alias path='echo -e ${PATH//:/\\n}'
alias pi="ping -Anc 5 1.1.1.1"
alias reload!='exec "$SHELL" -l'
alias zr='exec zsh'
alias rm="rm -iv"
alias srm="srm -iv"

# adding flag
alias free='free -m'
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

# Yazi - cd on quit
function y() {
  local tmp="/tmp/yazi-cwd-$$"
  yazi "$@" --cwd-file="$tmp"
  if [ -s "$tmp" ]; then
    local cwd
    cwd="$(cat -- "$tmp")"
    if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      builtin cd -- "$cwd" || return
    fi
  fi
  \rm -f -- "$tmp"
}

# Git - checkout git branch/tag with fzf
fco() {
  local tags branches target
  tags=$(
    git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}'
  ) || return
  branches=$(
    git branch --all | grep -v HEAD |
      sed "s/.* //" | sed "s#remotes/[^/]*/##" |
      sort -u | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}'
  ) || return
  target=$(
    (
      echo "$tags"
      echo "$branches"
    ) |
      fzf-tmux -- --no-hscroll --ansi +m -d "\t" -n 2
  ) || return
  git checkout "$(echo "$target" | awk '{print $2}')"
}

# -----------------------------------------------------------------------------
# History Substring Search Keybindings (must be after plugin load)
# -----------------------------------------------------------------------------
zmodload -F zsh/terminfo +p:terminfo
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

# -----------------------------------------------------------------------------
# iTerm2 Integration
# -----------------------------------------------------------------------------
[[ "$TERM_PROGRAM" == "iTerm.app" ]] && test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# -----------------------------------------------------------------------------
# Bun Completions
# -----------------------------------------------------------------------------
[ -s "/Users/jacebabin/.bun/_bun" ] && source "/Users/jacebabin/.bun/_bun"

# Added by Antigravity
export PATH="/Users/jacebabin/.antigravity/antigravity/bin:$PATH"

# Mole completion
if command -v mole &> /dev/null; then
  eval "$(mole completion zsh)"
fi

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
