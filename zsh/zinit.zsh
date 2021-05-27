# - - - - - - - - - - - - - - - - - - - -
# Zinit Configuration
# - - - - - - - - - - - - - - - - - - - -

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# - - - - - - - - - - - - - - - - - - - -
# Theme
# - - - - - - - - - - - - - - - - - - - -

# Most Themes Use This Option.
setopt promptsubst

# zinit wait lucid for \
#         OMZ::lib/git.zsh \
#     atload"unalias grv" \
#         OMZ::plugins/git/git.plugin.zsh

if [ "$(uname)" = "Darwin" ]; then
    zinit ice as"program" pick"target/release/starship" \
        atclone"cargo build --release" atpull"%atclone" \
        atload'eval $(starship init zsh)'
else
    zinit ice from"gh-r" as"program" mv"target/*/release/starship -> starship" \
        atload'eval $(starship init zsh)'
fi
zinit light starship/starship

# eval "$(starship init zsh)"

# - - - - - - - - - - - - - - - - - - - -
# Annexes
# - - - - - - - - - - - - - - - - - - - -

# Load a few important annexes, without Turbo (this is currently required for annexes)
zinit light-mode compile"handler" for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

# - - - - - - - - - - - - - - - - - - - -
# Plugins
# - - - - - - - - - - - - - - - - - - - -

zinit wait lucid light-mode for \
      OMZ::lib/compfix.zsh \
      OMZ::lib/completion.zsh \
      OMZ::lib/functions.zsh \
      OMZ::lib/diagnostics.zsh \
      OMZ::lib/grep.zsh \
      OMZ::lib/key-bindings.zsh \
      OMZ::lib/misc.zsh \
      OMZ::lib/spectrum.zsh \
      OMZ::lib/termsupport.zsh \
      OMZ::plugins/git-auto-fetch/git-auto-fetch.plugin.zsh \
  atinit"zicompinit; zicdreplay" \
        zdharma/fast-syntax-highlighting \
      OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh \
      OMZ::plugins/command-not-found/command-not-found.plugin.zsh \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  as"completion" \
      OMZ::plugins/docker/_docker \
      OMZ::plugins/thefuck/thefuck.plugin.zsh \
      htlsne/zplugin-rbenv \
      OMZ::plugins/pyenv/pyenv.plugin.zsh \
      zdharma/fast-syntax-highlighting \
      dominik-schwabe/zsh-fnm \
      lukechilds/zsh-nvm \
      Meroje/zsh-rbenv \
      wfxr/forgit \
      agkozak/zsh-z

# ENHANCD
# zinit ice wait"0b" lucid
# zinit light b4b4r07/enhancd
# export ENHANCD_FILTER=fzf:fzy:peco

# FZF
zinit ice lucid wait'0b' from"gh-r" as"command"
zinit light junegunn/fzf

# FZF BYNARY AND TMUX HELPER SCRIPT
zinit ice lucid wait'0c' as"command" id-as"junegunn/fzf-tmux" pick"bin/fzf-tmux"
zinit light junegunn/fzf

# BIND MULTIPLE WIDGETS USING FZF
zinit ice lucid wait'0c' multisrc"shell/{completion,key-bindings}.zsh" id-as"junegunn/fzf_completions" pick"/dev/null"
zinit light junegunn/fzf

# FZF-TAB
zinit ice wait"1" lucid
zinit light Aloxaf/fzf-tab

# Python
zinit ice atclone'PYENV_ROOT="$PWD" ./libexec/pyenv init - > zpyenv.zsh && git clone https://github.com/pyenv/pyenv-virtualenv ./plugins/pyenv-virtualenv' \
    atinit'export PYENV_ROOT="$PWD"' atpull"%atclone" \
    as'command' pick'bin/pyenv' src"zpyenv.zsh" nocompile'!'
zinit light pyenv/pyenv

# # EXA
zinit ice wait"2" lucid from"gh-r" as"program" mv"exa* -> exa"
zinit light ogham/exa
zinit ice wait blockf atpull'zinit creinstall -q .'

# DELTA
zinit ice lucid wait"0" as"program" from"gh-r" pick"delta*/delta"
zinit light 'dandavison/delta'

# BAT
zinit ice from"gh-r" as"program" mv"bat* -> bat" pick"bat/bat" atload"alias cat=bat"
zinit light sharkdp/bat

# BAT-EXTRAS
zinit ice wait"1" as"program" pick"src/batgrep.sh" lucid
zinit ice wait"1" as"program" pick"src/batdiff.sh" lucid
zinit light eth-p/bat-extras
alias rg=batgrep.sh
alias bd=batdiff.sh
alias man=batman.sh

# RIPGREP
zinit ice from"gh-r" as"program" mv"ripgrep* -> ripgrep" pick"ripgrep/rg"
zinit light BurntSushi/ripgrep

# NEOVIM
zinit ice from"gh-r" as"program" bpick"*appimage*" ver"stable" mv"nvim* -> nvim" pick"nvim"
zinit light neovim/neovim

# LAZYGIT
zinit ice lucid wait"0" as"program" from"gh-r" mv"lazygit* -> lazygit" atload"alias lg='lazygit'"
zinit light 'jesseduffield/lazygit'

# LAZYDOCKER
zinit ice lucid wait"0" as"program" from"gh-r" mv"lazydocker* -> lazydocker" atload"alias ld='lazydocker'"
zinit light 'jesseduffield/lazydocker'

# RANGER
zinit ice depth'1' as"program" pick"ranger.py"
zinit light ranger/ranger

# FD
zinit ice as"command" from"gh-r" mv"fd* -> fd" pick"fd/fd"
zinit light sharkdp/fd

# GH-CLI
zinit ice lucid wait"0" as"program" from"gh-r" pick"usr/bin/gh"
zinit light "cli/cli"

# TMUX
zinit ice from"gh-r" as"program" mv"tmux* -> tmux" pick"tmux" atload"alias tmux=tmux"
zinit light tmux/tmux

# BIT
zinit ice lucid wait"0" as"program" from"gh-r" pick"bit"
zinit light "chriswalz/bit"

# Recommended Be Loaded Last.
zinit ice wait blockf lucid atpull'zinit creinstall -q .'
zinit load zsh-users/zsh-completions

# - - - - - - - - - - - - - - - - - - - -
# FANCY-CTRL-Z
# - - - - - - - - - - - - - - - - - - - -

function fg-fzf() {
	job="$(jobs | fzf -0 -1 | sed -E 's/\[(.+)\].*/\1/')" && echo '' && fg %$job
}

function fancy-ctrl-z () {
	if [[ $#BUFFER -eq 0 ]]; then
		BUFFER=" fg-fzf"
		zle accept-line -w
	else
		zle push-input -w
		zle clear-screen -w
	fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# - - - - - - - - - - - - - - - - - - - -
# FZF SETTINGS
# - - - - - - - - - - - - - - - - - - - -

export FZF_DEFAULT_OPTS="
--ansi
--layout=default
--info=inline
--height=50%
--multi
--preview-window=right:50%
--preview-window=sharp
--preview-window=cycle
--preview '([[ -f {} ]] && (bat --style=numbers --color=always --line-range :500 {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
--prompt='λ -> '
--pointer='|>'
--marker='✓'
--bind 'ctrl-e:execute(nvim {} < /dev/tty > /dev/tty 2>&1)' > selected
--bind 'ctrl-v:execute(code {+})'"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# - - - - - - - - - - - - - - - - - - - -
# FZF-GC-PROJECT
# - - - - - - - - - - - - - - - - - - - -

function fzf-gcloud-config-set-project() {
    local project="$(gcloud projects list |
        fzf --header-lines=1 --reverse |
        awk '{ print $1 }')"

    if [[ -n "$project" ]]; then
        gcloud config set project "$project"
    fi
}
zle -N fzf-gcloud-config-set-project
bindkey '^G' fzf-gcloud-config-set-project
