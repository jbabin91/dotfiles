# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && . "$HOME/.fig/shell/zshrc.pre.zsh"

export LC_ALL="en_US.UTF-8"
export EDITOR=nvim

# Path to your own oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# themes ---------------------------------------------------------------
ZSH_THEME="robbyrussell"

# Kitty ------------------------------------------------------------------------
autoload -Uz compinit
compinit
# Completion for kitty
kitty + complete setup zsh | source /dev/stdin

source ~/.config/zsh/path.sh
source ~/.config/zsh/plugins.sh

source $ZSH/oh-my-zsh.sh

source ~/.config/zsh/aliases.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide
eval "$(zoxide init zsh)"

# Starship
eval "$(starship init zsh)"

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# Fig post block. Keep at the bottom of this file.
# [[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && . "$HOME/.fig/shell/zshrc.post.zsh"
