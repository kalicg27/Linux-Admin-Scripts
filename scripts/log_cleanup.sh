#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo)." >&2
  exit 1
fi

echo "== Journal cleanup (keeping 7 days or 200M, whichever smaller) =="
if command -v journalctl >/dev/null 2>&1; then
  journalctl --vacuum-time=7d || true
  journalctl --vacuum-size=200M || true
else
  echo "journalctl not found; skipping systemd journal cleanup."
fi

echo
echo "== Package caches =="
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

echo "Done."
