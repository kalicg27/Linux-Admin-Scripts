#!/usr/bin/env bash
set -euo pipefail

echo "== Host =="
hostnamectl 2>/dev/null || uname -a

echo
echo "== Uptime & Load =="
uptime

echo
echo "== CPU =="
lscpu 2>/dev/null | egrep 'Model name|CPU\(s\)|Thread|Core|Socket' || true

echo
echo "== Memory =="
free -h

echo
echo "== Disk =="
df -h | awk 'NR==1 || /^\/dev\//'

echo
echo "== Top CPU processes =="
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 10

echo
echo "== Top MEM processes =="
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 10
