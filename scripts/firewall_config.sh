#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: sudo $0 [--enable] [--reset] [--allow-ssh] [--deny-all-incoming]

Opinionated UFW configuration. Idempotent and safe to re-run.

Options:
  --enable            Enable UFW (default deny incoming, allow outgoing).
  --reset             Reset UFW to defaults before applying rules.
  --allow-ssh         Allow OpenSSH (port 22).
  --deny-all-incoming Set default incoming policy to deny.
  -h                  Help.
EOF
}

ENABLE=false
RESET=false
ALLOW_SSH=false
DENY_IN=false

for arg in "$@"; do
  case "$arg" in
    --enable) ENABLE=true ;;
    --reset) RESET=true ;;
    --allow-ssh) ALLOW_SSH=true ;;
    --deny-all-incoming) DENY_IN=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo)." >&2
  exit 1
fi

if ! command -v ufw >/dev/null 2>&1; then
  echo "UFW is not installed."
  exit 1
fi

if $RESET; then
  echo "Resetting UFW..."
  yes | ufw reset
fi

if $DENY_IN; then
  ufw default deny incoming
fi
ufw default allow outgoing

if $ALLOW_SSH; then
  ufw allow OpenSSH || ufw allow 22/tcp
fi

if $ENABLE; then
  ufw --force enable
fi

echo "== UFW status =="
ufw status verbose
