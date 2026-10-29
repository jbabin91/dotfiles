#!/bin/sh
# Karabiner-Elements replaces a symlink when it saves, so its config is a copy
# synced on every apply: the live file wins once it exists, and is seeded from
# the repo until then. A failed copy warns rather than stopping the apply.

: "${CHEZMOI_SOURCE_DIR:?is unset; run this through chezmoi apply}"
src="$CHEZMOI_SOURCE_DIR/../config/karabiner/karabiner.json"
dest="$HOME/.config/karabiner/karabiner.json"

# Renamed into place, so an interrupted copy never takes the real name for the
# next apply to sync onward, and a leftover link is replaced, not written through.
copy_over() {
  # mv would move the temp file into a directory, or one a link leads to.
  [ -d "$2" ] && return 1
  tmp="$2.tmp.$$"
  if cp "$1" "$tmp" && mv -f "$tmp" "$2"; then return 0; fi
  rm -f "$tmp"
  return 1
}

if [ -f "$dest" ] && [ ! -L "$dest" ]; then
  cmp -s "$dest" "$src" && exit 0
  if [ ! -s "$dest" ]; then
    echo "  karabiner: $dest is empty; left $src as it was" >&2
    exit 0
  fi
  copy_over "$dest" "$src" && echo "  karabiner: live → dotfiles" && exit 0
elif [ -f "$src" ]; then
  mkdir -p "${dest%/*}" && copy_over "$src" "$dest" &&
    echo "  karabiner: dotfiles → live (bootstrap)" && exit 0
else
  exit 0
fi
echo "  karabiner: could not sync $dest with $src" >&2
exit 0
