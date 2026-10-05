# Shared setup and status output, ported from dotfiles-macos. Phases open
# with a ruled section header, results print as a mark plus a tag, and
# dry-run lines stay plain "+" commands. Color is used only on a terminal
# and only when NO_COLOR is unset. The summary counts ok / local / missing
# results so a run can be scanned at a glance.

_count_ok=0
_count_local=0
_count_missing=0

_output_color() {
  local fd="${1:-1}"
  [[ -z "${NO_COLOR:-}" ]] || return 1
  [[ -t "$fd" ]]
}

section() {
  local title="$1"
  local text="── ${title}"
  if [[ "${DRY_RUN:-false}" == true ]]; then
    text="${text}  (preview)"
  fi
  text="${text} "
  local width=40
  local pad=$((width - ${#text}))
  ((pad < 2)) && pad=2
  local rule
  rule="$(printf '%*s' "$pad" '')"
  rule="${rule// /─}"
  if _output_color 1; then
    printf '\033[2m%s%s\033[0m\n' "$text" "$rule"
  else
    printf '%s%s\n' "$text" "$rule"
  fi
}

report() {
  local tag="$1"
  shift
  local mark paint
  case "$tag" in
    ok | linked | pinned | alias | changed)
      mark='✓'
      paint=32
      _count_ok=$((_count_ok + 1))
      ;;
    local | backup)
      mark='·'
      paint=2
      _count_local=$((_count_local + 1))
      ;;
    missing | broken | wrong | error)
      mark='✗'
      paint=31
      _count_missing=$((_count_missing + 1))
      ;;
    *)
      mark='·'
      paint=2
      _count_local=$((_count_local + 1))
      ;;
  esac

  local painted="$mark"
  if _output_color 1; then
    painted="$(printf '\033[%sm%s\033[0m' "$paint" "$mark")"
  fi
  printf '  %s  %-8s %s\n' "$painted" "$tag" "$*"
}

log() {
  report ok "$*"
}

die() {
  if _output_color 2; then
    printf '\033[31m  ✗  %-8s %s\033[0m\n' error "$*" >&2
  else
    printf '  ✗  %-8s %s\n' error "$*" >&2
  fi
  exit 1
}

run() {
  if [[ "${DRY_RUN:-false}" == true ]]; then
    printf '  + '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

output_summary() {
  section Done
  printf '  %d ok   %d local   %d missing\n' "$_count_ok" "$_count_local" "$_count_missing"
}