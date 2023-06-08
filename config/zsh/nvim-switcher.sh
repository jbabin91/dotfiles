command -v nvim >/dev/null && {
  items=()

  [ -d ${HOME}/.config/nvim ] && {
    alias nvim-default="NVIM_APPNAME=nvim nvim"
    items+=("default")
  }
  [ -d ${HOME}/.config/nvim-LazyVim ] && {
    alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
    items+=("LazyVim")
  }
  [ -d ${HOME}/.config/nvim-kickstart ] && {
    alias nvim-kick="NVIM_APPNAME=kickstart nvim"
    items+=("kickstart")
  }
  [ -d ${HOME}/.config/NvChad ] && {
    alias nvim-chad="NVIM_APPNAME=NvChad nvim"
    items+=("NvChad")
  }
  [ -d ${HOME}/.config/AstroNvim ] && {
    alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
    items+=("AstroNvim")
  }

  function nvims() {
    config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
    if [[ -z $config ]]; then
      echo "Nothing selected"
      return 0
    elif [[ $config == "default" ]]; then
      config=""
    fi
    NVIM_APPNAME=$config nvim $@
  }

  # if [ -n "$($SHELL -c 'echo $ZSH_VERSION')" ]; then
  #   bindkey -s ^a "nvims\n"
  # elif [ -n "$($SHELL -c 'echo $BASH_VERSION')" ]; then
  #   bind -x '"\C-a": nvims'
  # else
  #   bindkey -s ^a "nvims\n"
  # fi
}
