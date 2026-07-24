#!/usr/bin/env bash
# Symlink every skill in this repo into ~/.claude/skills so Claude Code picks it up.
# Safe to re-run; skips existing links, warns on conflicts, prunes dead links.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude/skills"
mkdir -p "$DEST"

for dir in "$SRC"/*/; do
  name="$(basename "$dir")"
  [[ -f "$dir/SKILL.md" ]] || continue
  target="$DEST/$name"
  if [[ -L "$target" ]]; then
    [[ "$(readlink "$target")" == "$dir" || "$(readlink "$target")" == "${dir%/}" ]] \
      || echo "skip: $name already links elsewhere ($(readlink "$target"))"
  elif [[ -e "$target" ]]; then
    echo "skip: $name exists in $DEST and is not a symlink"
  else
    ln -s "$dir" "$target"
    echo "linked: $name"
  fi
done

# Remove symlinks in ~/.claude/skills that point into this repo but whose source is gone
for link in "$DEST"/*; do
  if [[ -L "$link" && "$(readlink "$link")" == "$SRC"/* && ! -e "$link" ]]; then
    rm "$link"
    echo "pruned: $(basename "$link") (source removed)"
  fi
done
