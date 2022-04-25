export FZF_DEFAULT_COMMAND='rg --files --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export RIPGREP_CONFIG_PATH="$HOME/.rgrc"

# Support zoxide in Vim command mode, which isn't an interactive shell bu
# default. It's okay if `zoxide` isn't found. Outside of Vim, starting a new
# shell, it may not be on the PATH yet.
if ["$(command -v zoxide)"]; then
  eval "$(zoxide init zsh)"
fi

# fco - checkout git branch/tag
fco() {
  local tags branches target
  tags=$(
    git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
    git branch --all | grep -v HEAD             |
    sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
    sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") |
    fzf-tmux -- --no-hscroll --ansi +m -d "\t" -n 2) || return
  git checkout "$(echo "$target" | awk '{print $2}')"
}
