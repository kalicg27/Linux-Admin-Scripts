#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: sudo $0 [--disable-root] [--disable-passwords] [--max-auth 3]

Safely harden /etc/ssh/sshd_config with an automatic backup and restart.

Options:
  --disable-root         Set PermitRootLogin no
  --disable-passwords    Set PasswordAuthentication no (forces key-based auth)
  --max-auth N           Set MaxAuthTries to N (default: 3)
  -h                     Help

A dated backup will be saved to /etc/ssh/sshd_config.BAK-YYYYmmdd-HHMMSS
EOF
}

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo)." >&2
  exit 1
fi

DISABLE_ROOT=false
DISABLE_PASSWORDS=false
MAX_AUTH=3

while [[ $# -gt 0 ]]; do
  case "$1" in
    --disable-root) DISABLE_ROOT=true; shift ;;
    --disable-passwords) DISABLE_PASSWORDS=true; shift ;;
    --max-auth) MAX_AUTH="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

SSHD="/etc/ssh/sshd_config"
if [[ ! -f "$SSHD" ]]; then
  echo "Cannot find $SSHD" >&2
  exit 1
fi

STAMP=$(date +"%Y%m%d-%H%M%S")
cp "$SSHD" "${SSHD}.BAK-${STAMP}"
echo "Backup saved: ${SSHD}.BAK-${STAMP}"

# Ensure settings are present or updated (idempotent)
set_kv() {
  local key="$1"; shift
  local val="$*"
  if grep -Eiq "^[#]*\s*${key}\b" "$SSHD"; then
    sed -i -E "s|^[#]*\s*${key}\b.*|${key} ${val}|I" "$SSHD"
  else
    echo "${key} ${val}" >> "$SSHD"
  fi
}

set_kv "Protocol" "2"
set_kv "MaxAuthTries" "$MAX_AUTH"

if $DISABLE_ROOT; then
  set_kv "PermitRootLogin" "no"
fi

if $DISABLE_PASSWORDS; then
  set_kv "PasswordAuthentication" "no"
fi

echo "Testing sshd configuration..."
if command -v sshd >/dev/null 2>&1; then
  sshd -t
fi

echo "Reloading sshd..."
if command -v systemctl >/dev/null 2>&1; then
  systemctl reload sshd || systemctl restart sshd
else
  service ssh reload || service ssh restart
fi

echo "Done. Verify that you can log in via a separate session before disconnecting."
