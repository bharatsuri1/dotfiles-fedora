readonly DOCKER_REPOSITORY_URL="https://download.docker.com/linux/fedora/docker-ce.repo"
readonly DOCKER_REPOSITORY_FILE="/etc/yum.repos.d/docker-ce.repo"
readonly DOCKER_PACKAGES=(
  docker-ce
  docker-ce-cli
  containerd.io
  docker-buildx-plugin
  docker-compose-plugin
)

install_docker() {
  if [[ -r "$DOCKER_REPOSITORY_FILE" ]]; then
    log 'official Docker repository already configured'
  elif $DRY_RUN; then
    printf '+ curl -fsSL %q | sudo install -m 0644 /dev/stdin %q\n' \
      "$DOCKER_REPOSITORY_URL" "$DOCKER_REPOSITORY_FILE"
  else
    local repository
    repository="$(mktemp)"
    curl -fsSLo "$repository" "$DOCKER_REPOSITORY_URL"
    run sudo install -m 0644 "$repository" "$DOCKER_REPOSITORY_FILE"
    rm -f -- "$repository"
  fi

  local -a missing=()
  local package
  for package in "${DOCKER_PACKAGES[@]}"; do
    package_installed "$package" || missing+=("$package")
  done

  if ((${#missing[@]} == 0)); then
    log 'Docker packages already installed'
  else
    log "installing Docker packages: ${missing[*]}"
    local -a command=(sudo dnf install)
    $ASSUME_YES && command+=(--assumeyes)
    run "${command[@]}" "${missing[@]}"
  fi

  if systemctl is-enabled docker.service >/dev/null 2>&1 &&
    systemctl is-active docker.service >/dev/null 2>&1; then
    log 'Docker service already enabled and active'
  else
    run sudo systemctl enable --now docker.service
  fi

  if id -nG "$USER" | tr ' ' '\n' | grep -Fxq docker; then
    log "$USER already belongs to the docker group"
  else
    run sudo usermod --append --groups docker "$USER"
    log 'log out and back in before using Docker without sudo'
  fi
}
