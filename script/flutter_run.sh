#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUPABASE_PORT="${SUPABASE_PORT:-54321}"
DEFAULT_ENVIRONMENT="local"

print_usage() {
  cat <<'EOF'
Usage: ./script/flutter_run.sh [local|staging|prod] [flutter run args...]

Examples:
  ./script/flutter_run.sh
  ./script/flutter_run.sh staging -d chrome
  ./script/flutter_run.sh prod --release
EOF
}

is_valid_environment() {
  case "${1}" in
    local|staging|prod) return 0 ;;
    *) return 1 ;;
  esac
}

get_local_ip() {
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY' && return 0
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

try:
    sock.connect(("8.8.8.8", 80))
    print(sock.getsockname()[0])
finally:
    sock.close()
PY
  fi

  if [[ "$(uname -s)" == "Darwin" ]]; then
    local default_interface
    default_interface="$(route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')"

    if [[ -n "${default_interface}" ]]; then
      ipconfig getifaddr "${default_interface}" 2>/dev/null && return 0
    fi

    for interface in en0 en1; do
      ipconfig getifaddr "${interface}" 2>/dev/null && return 0
    done
  fi

  if command -v ip >/dev/null 2>&1; then
    ip route get 1.1.1.1 2>/dev/null | awk '
      {
        for (i = 1; i <= NF; i++) {
          if ($i == "src") {
            print $(i + 1)
            exit
          }
        }
      }
    ' && return 0
  fi

  if command -v hostname >/dev/null 2>&1; then
    hostname -I 2>/dev/null | awk '{print $1}' && return 0
  fi

  return 1
}

build_dart_define_args() {
  local environment="$1"

  printf '%s\n' "--dart-define=APP_ENV=${environment}"

  if [[ "${environment}" == "local" ]]; then
    local local_ip
    local_ip="$(get_local_ip | tr -d '[:space:]')"

    if [[ -z "${local_ip}" ]]; then
      echo "Unable to determine a local IP address." >&2
      exit 1
    fi

    printf '%s\n' "--dart-define=SUPABASE_URL=http://${local_ip}:${SUPABASE_PORT}"
  fi
}

environment="${DEFAULT_ENVIRONMENT}"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  print_usage
  exit 0
fi

if [[ $# -gt 0 ]] && is_valid_environment "${1}"; then
  environment="${1}"
  shift
fi

mapfile -t dart_define_args < <(build_dart_define_args "${environment}")

echo "Running flutter run with APP_ENV=${environment}" >&2
exec flutter run "${dart_define_args[@]}" "$@"
