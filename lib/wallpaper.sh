#!/usr/bin/env bash

wallpapers_dir() {
  printf '%s\n' "${XDG_WALLPAPERS_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers}"
}

current_wallpaper() {
  local directory
  directory="$(wallpapers_dir)"
  [[ -e "$directory/current" ]] || return 1
  readlink -f -- "$directory/current"
}

initialize_wallpapers() {
  local directory first

  directory="$(wallpapers_dir)"
  mkdir -p -- "$directory"

  if [[ ! -e "$directory/current" ]]; then
    first="$(find "$directory" -maxdepth 1 -type f \
      \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
      -print -quit)"
    [[ -n "$first" ]] || return 1
    ln -s -- "$first" "$directory/current"
  fi
}

sync_packaged_wallpapers() {
  local source_dir="$1"
  local directory wallpaper

  directory="$(wallpapers_dir)"
  mkdir -p -- "$directory"
  while IFS= read -r -d '' wallpaper; do
    install -m 0644 -- "$wallpaper" "$directory/$(basename -- "$wallpaper")"
  done < <(find "$source_dir" -maxdepth 1 -type f -print0)
}
