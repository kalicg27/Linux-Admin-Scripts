#!/usr/bin/env bash
set -euo pipefail   # stop script if error, unset var, or pipe fails

# ---------------------------------------------------------
# add_user.sh
# A small helper script to add a new user on Linux.
# Lets you choose a username and (optionally) make them sudo.
# ---------------------------------------------------------

# quick help message
usage() {
  cat <<EOF
Usage: sudo $0 -u USERNAME [-s]

Create a new local user with a home folder.
Options:
  -u USERNAME   (required) who you want to create
  -s            add this user to the sudo group
  -h            show this help
EOF
}

USERNAME=""
ADD_SUDO=false

# grab command-line options (-u, -s, -h)
while getopts ":u:sh" opt; do
  case "$opt" in
    u) USERNAME="$OPTARG" ;;  # save the username
    s) ADD_SUDO=true ;;       # if -s given, mark sudo
    h) usage; exit 0 ;;       # show help and exit
    *) usage; exit 1 ;;
  esac
done

# if no username given, complain
if [[ -z "${USERNAME}" ]]; then
  echo "Need a username with -u" >&2
  usage; exit 1
fi

# must run with root (or sudo)
if [[ $EUID -ne 0 ]]; then
  echo "Run this script with sudo/root." >&2
  exit 1
fi

# if user already exists, just say so
if id -u "$USERNAME" >/dev/null 2>&1; then
  echo "ℹUser '$USERNAME' already exists."
  exit 0
fi

# actually create the user
echo "👤 Creating user '$USERNAME'..."
useradd -m -s /bin/bash "$USERNAME"

# lock the account until password is set
passwd -l "$USERNAME" >/dev/null 2>&1 || true
echo "User created but login is locked. 
➡️ Set a password with: sudo passwd $USERNAME"

# if -s flag was used, add to sudo/wheel group
if $ADD_SUDO; then
  if getent group sudo >/dev/null 2>&1; then
    usermod -aG sudo "$USERNAME"
    echo "Added '$USERNAME' to sudo group."
  elif getent group wheel >/dev/null 2>&1; then
    usermod -aG wheel "$USERNAME"
    echo "Added '$USERNAME' to wheel group."
  else
    echo "No sudo/wheel group found on this system."
  fi
fi

echo " Done!"
