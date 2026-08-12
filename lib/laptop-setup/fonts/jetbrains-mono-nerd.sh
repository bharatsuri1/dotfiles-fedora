readonly FONT_DEST="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/JetBrainsMonoNerd"
readonly NERD_FONTS_VERSION="3.5.0"
readonly NERD_FONTS_SHA256="0227b220360a6f819b9ead92343e8112b34733054782561af50cfba1e8afab63"
readonly NERD_FONTS_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONTS_VERSION}/JetBrainsMono.tar.xz"

font_source_dir() {
  local sibling="$REPO_ROOT/../dotfiles-omarchy/assets/fonts/JetBrainsMono"
  [[ -f "$sibling/JetBrainsMonoNerdFont-Regular.ttf" ]] && printf '%s\n' "$sibling"
}

install_font_files() {
  local source_dir="${1:-}"
  local font

  if $DRY_RUN; then
    local font_count
    font_count="$(find "$source_dir" -maxdepth 1 -type f -name '*.ttf' | wc -l)"
    printf '+ install %s TTF files from %q into %q\n' "$font_count" "$source_dir" "$FONT_DEST"
    printf '+ fc-cache -f\n'
    return
  fi

  run install -d "$FONT_DEST"
  while IFS= read -r -d '' font; do
    run install -m 0644 "$font" "$FONT_DEST/"
  done < <(find "$source_dir" -maxdepth 1 -type f -name '*.ttf' -print0 | sort -z)
  run fc-cache -f
}

install_jetbrains_mono_nerd_font() {
  local source_dir
  source_dir="$(font_source_dir || true)"

  if [[ -n "$source_dir" ]]; then
    log "installing JetBrains Mono Nerd Font v${NERD_FONTS_VERSION} from sibling asset repository"
    install_font_files "$source_dir"
    return
  fi

  if $DRY_RUN; then
    log "would download and verify JetBrains Mono Nerd Font v${NERD_FONTS_VERSION}"
    printf '+ curl -fL --retry 3 -o <temporary-archive> %q\n' "$NERD_FONTS_URL"
    printf '+ verify SHA-256 %s\n' "$NERD_FONTS_SHA256"
    printf '+ install TTF files into %q\n' "$FONT_DEST"
    return
  fi

  local temp_dir archive
  temp_dir="$(mktemp -d)"
  archive="$temp_dir/JetBrainsMono.tar.xz"

  log "downloading JetBrains Mono Nerd Font v${NERD_FONTS_VERSION}"
  curl -fL --retry 3 -o "$archive" "$NERD_FONTS_URL"
  printf '%s  %s\n' "$NERD_FONTS_SHA256" "$archive" | sha256sum --check
  tar -xJf "$archive" -C "$temp_dir"
  install_font_files "$temp_dir"
  rm -rf -- "$temp_dir"
}
