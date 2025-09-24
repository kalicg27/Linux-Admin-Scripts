#!/usr/bin/env bash
set -euo pipefail

if ! command -v systemctl >/dev/null 2>&1; then
  echo "systemctl not found (non-systemd system?)." >&2
  exit 1
fi

if [[ $# -eq 0 ]]; then
  echo "== Failed services =="
  systemctl --failed || true
  echo
  echo "Usage: $0 SERVICE [SERVICE ...]  # to check specific services"
  exit 0
fi

for svc in "$@"; do
  echo "== $svc =="
  systemctl status "$svc" --no-pager || true
  echo
done
