#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env.local"
SUPABASE_PORT="${SUPABASE_PORT:-54321}"

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

update_env_file() {
  local supabase_url="$1"
  local temp_file
  local found=0

  touch "${ENV_FILE}"
  temp_file="$(mktemp)"

  while IFS= read -r line || [[ -n "${line}" ]]; do
    if [[ "${line}" == SUPABASE_URL=* ]]; then
      printf 'SUPABASE_URL=%s\n' "${supabase_url}" >> "${temp_file}"
      found=1
    else
      printf '%s\n' "${line}" >> "${temp_file}"
    fi
  done < "${ENV_FILE}"

  if [[ "${found}" -eq 0 ]]; then
    printf 'SUPABASE_URL=%s\n' "${supabase_url}" >> "${temp_file}"
  fi

  mv "${temp_file}" "${ENV_FILE}"
}

LOCAL_IP="$(get_local_ip | tr -d '[:space:]')"

if [[ -z "${LOCAL_IP}" ]]; then
  echo "Unable to determine a local IP address." >&2
  exit 1
fi

SUPABASE_URL="http://${LOCAL_IP}:${SUPABASE_PORT}"
update_env_file "${SUPABASE_URL}"

echo "Updated ${ENV_FILE} with SUPABASE_URL=${SUPABASE_URL}"

exec flutter run --dart-define-from-file="${ENV_FILE}" "$@"
