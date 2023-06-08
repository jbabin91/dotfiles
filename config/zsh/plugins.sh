plugins=(
  catimg
  colored-man-pages
  docker
  extract
  gem
  gitfast
  last-working-dir
  npm
  pip
  sudo
  yarn
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"                                       # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

# iTerm integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# zoxide
eval "$(zoxide init zsh)"

# Starship
eval "$(starship init zsh)"

# fast node manager
eval "$(fnm env --use-on-cd)"

# direnv
eval "$(direnv hook zsh)"

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true
