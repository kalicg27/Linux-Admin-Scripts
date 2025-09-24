#!/usr/bin/env bash
set -euo pipefail

TARGETS="${@:-1.1.1.1 8.8.8.8}"

echo "== Interfaces =="
ip -brief addr 2>/dev/null || ifconfig -a 2>/dev/null || true

echo
echo "== Routes =="
ip route 2>/dev/null || route -n 2>/dev/null || true

echo
echo "== DNS (resolv.conf) =="
cat /etc/resolv.conf 2>/dev/null || true

echo
echo "== Connectivity tests =="
for t in $TARGETS; do
  echo "-- ping $t --"
  ping -c 3 -W 2 "$t" 2>&1 || echo "Ping to $t failed"
  echo
done
