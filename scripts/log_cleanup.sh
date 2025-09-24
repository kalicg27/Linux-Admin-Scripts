#!/usr/bin/env bash
set -euo pipefail   # exit if error, unset variable, or pipe failure

# ---------------------------------------------------------
# log_cleanup.sh
# Cleans up system logs and package caches.
# - Shrinks systemd journal size (or keeps only recent logs)
# - Clears package manager cache (apt, yum, dnf, zypper)
# Helps free disk space and keep logs manageable.
# ---------------------------------------------------------

# must run as root
if [[ $EUID -ne 0 ]]; then
  echo "Error: run this script with sudo or as root." >&2
  exit 1
fi

echo "== Cleaning system logs =="

# systemd journal cleanup (keep 7 days or max 200 MB)
if command -v journalctl >/dev/null 2>&1; then
  journalctl --vacuum-time=7d || true
  journalctl --vacuum-size=200M || true
else
  echo "No journalctl found (maybe non-systemd system)."
fi

echo
echo "== Cleaning package caches =="

# check which package manager exists and clean accordingly
if command -v apt-get >/dev/null 2>&1; then
  apt-get clean
  apt-get autoremove -y || true
elif command -v dnf >/dev/null 2>&1; then
  dnf clean all -y || true
elif command -v yum >/dev/null 2>&1; then
  yum clean all -y || true
elif command -v zypper >/dev/null 2>&1; then
  zypper clean -a || true
else
  echo "No known package manager detected."
fi

echo "Cleanup finished."
