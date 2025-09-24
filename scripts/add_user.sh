#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: sudo $0 -u USERNAME [-s]
Create a local user with a home directory. Optional: add to sudo group.

Options:
  -u USERNAME   Required. The username to create.
  -s            Add the user to the 'sudo' group.
  -h            Show help.
EOF
}

USERNAME=""
ADD_SUDO=false

while getopts ":u:sh" opt; do
  case "$opt" in
    u) USERNAME="$OPTARG" ;;
    s) ADD_SUDO=true ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

if [[ -z "${USERNAME}" ]]; then
  echo "ERROR: -u USERNAME is required" >&2
  usage; exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo)." >&2
  exit 1
fi

if id -u "$USERNAME" >/dev/null 2>&1; then
  echo "User '$USERNAME' already exists."
  exit 0
fi

echo "Creating user '$USERNAME'..."
useradd -m -s /bin/bash "$USERNAME"
passwd -l "$USERNAME" >/dev/null 2>&1 || true
echo "User created and login is locked. Set a password with: sudo passwd $USERNAME"

if $ADD_SUDO; then
  if getent group sudo >/dev/null 2>&1; then
    usermod -aG sudo "$USERNAME"
    echo "Added '$USERNAME' to 'sudo' group."
  elif getent group wheel >/dev/null 2>&1; then
    usermod -aG wheel "$USERNAME"
    echo "Added '$USERNAME' to 'wheel' group."
  else
    echo "WARN: No 'sudo' or 'wheel' group found."
  fi
fi

echo "Done."
