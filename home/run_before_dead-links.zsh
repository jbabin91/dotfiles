#!/bin/zsh -f
# Removes the dead links into this repo that a moved or deleted repo file leaves
# in ~ and ~/.config. Dead links pointing anywhere else belong to other tools.

: "${CHEZMOI_SOURCE_DIR:?is unset; run this through chezmoi apply}"
repo=${CHEZMOI_SOURCE_DIR:h:P}

# chezmoi's own symlink_ entries are left to it: deleting one makes every later
# apply stop to ask about it.
out=$("$CHEZMOI_EXECUTABLE" managed --source "$CHEZMOI_SOURCE_DIR" --destination "$HOME" \
  --include=symlinks --path-style=absolute) || {
  print -u2 "  dead-links: chezmoi managed failed, so no links were swept"
  exit 0
}
typeset -A managed
for path_ in ${(f)out}; do managed[$path_]=1; done

# (-@) matches dangling links. Each target is resolved a component at a time,
# splicing in every link met on the way and treating missing components as
# plain names, as realpath does; zsh's :P stops at a dangling link part-way up
# a path.
for link in $HOME/*(ND-@) $HOME/.config/**/*(ND-@); do
  (( ${+managed[${link:a}]} )) && continue
  target=/ hops=0
  parts=(${(s:/:)link})
  while (( $#parts )); do
    part=$parts[1]
    shift parts
    case $part in
      .) ;;
      ..) target=${target:h} ;;
      *)
        if [[ -L ${target%/}/$part ]] && (( ++hops <= 40 )); then
          next=$(readlink -- ${target%/}/$part)
          [[ $next == /* ]] && target=/
          parts=(${(s:/:)next} $parts)
        else
          target=${target%/}/$part
        fi
        ;;
    esac
  done
  [[ $target == "$repo"/* ]] || continue
  # One undeletable link should not stop every config from deploying.
  if rm -f -- $link; then
    print "  removed dead link $link -> $target"
  else
    print -u2 "  dead-links: could not remove $link -> $target; remove it by hand"
  fi
done
