#!/usr/bin/env bash
set -euo pipefail

echo "== Disk usage (df -h) =="
df -h | awk 'NR==1 || /^\/dev\//' 

echo
echo "== Largest directories under / (top 10) =="
du -x -h --max-depth=1 / 2>/dev/null | sort -h | tail -n 10

echo
echo "== Top 10 largest files on root filesystem =="
# POSIX-ish size sort via -S; restrict to root filesystem
find / -xdev -type f -printf "%s\t%p\n" 2>/dev/null | sort -n | tail -n 10 | awk '{printf "%10d  %s\n", $1, $2}'
