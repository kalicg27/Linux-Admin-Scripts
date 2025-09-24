#!/usr/bin/env bash
set -euo pipefail   # exit if error, unset variable, or pipe failure

# ---------------------------------------------------------
# backup_home.sh
# Make a compressed backup of a user’s home directory.
# Skips common cache and temporary folders to save space.
# Produces a tar.gz file with timestamp in the name.
# ---------------------------------------------------------

# print usage instructions
usage() {
  cat <<EOF
Usage: sudo $0 -u USERNAME [-o OUTPUT_DIR]

Options:
  -u USERNAME      (required) user whose home directory will be backed up
  -o OUTPUT_DIR    directory where backup will be stored (default: /var/backups)
  -h               show this help
EOF
}

USER=""
OUT="/var/backups"

# parse options
while getopts ":u:o:h" opt; do
  case "$opt" in
    u) USER="$OPTARG" ;;   # username
    o) OUT="$OPTARG" ;;    # custom output directory
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

# make sure username was given
if [[ -z "$USER" ]]; then
  echo "Error: username is required (-u)" >&2
  usage; exit 1
fi

# must run as root
if [[ $EUID -ne 0 ]]; then
  echo "Error: run this script with sudo or as root." >&2
  exit 1
fi

# find the home directory for this user
HOME_DIR=$(getent passwd "$USER" | cut -d: -f6)
if [[ -z "${HOME_DIR}" || ! -d "${HOME_DIR}" ]]; then
  echo "Error: home directory not found for user '$USER'." >&2
  exit 1
fi

# make sure output directory exists
mkdir -p "$OUT"

# create timestamped archive name
STAMP=$(date +"%Y%m%d-%H%M%S")
TARGET="${OUT}/${USER}-home-${STAMP}.tar.gz"

# run the backup
echo "Backing up ${HOME_DIR} to ${TARGET}"
tar --exclude="
