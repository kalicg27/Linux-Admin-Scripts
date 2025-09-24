#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: sudo $0 -u USERNAME [-o OUTPUT_DIR]

Create a compressed backup of a user's home directory.
Excludes common cache paths. Produces: OUTPUT_DIR/USERNAME-home-YYYYmmdd-HHMMSS.tar.gz

Options:
  -u USERNAME      Required. Which user's home to back up.
  -o OUTPUT_DIR    Default: /var/backups
  -h               Help
EOF
}

USER=""
OUT="/var/backups"

while getopts ":u:o:h" opt; do
  case "$opt" in
    u) USER="$OPTARG" ;;
    o) OUT="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

if [[ -z "$USER" ]]; then
  echo "ERROR: -u USERNAME is required" >&2
  usage; exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo)." >&2
  exit 1
fi

HOME_DIR=$(getent passwd "$USER" | cut -d: -f6)
if [[ -z "${HOME_DIR}" || ! -d "${HOME_DIR}" ]]; then
  echo "ERROR: home directory not found for user '$USER'." >&2
  exit 1
fi

mkdir -p "$OUT"
STAMP=$(date +"%Y%m%d-%H%M%S")
TARGET="${OUT}/${USER}-home-${STAMP}.tar.gz"

echo "Backing up ${HOME_DIR} -> ${TARGET}"
tar --exclude="${HOME_DIR}/.cache" \
    --exclude="${HOME_DIR}/Downloads" \
    --exclude="${HOME_DIR}/.local/share/Trash" \
    -czf "${TARGET}" -C "${HOME_DIR}" .

echo "Backup complete: ${TARGET}"
