# Linux Admin Scripts

Small, practical Linux administration scripts suitable for IT Infrastructure roles (CloudLinux, DevOps, SRE, SysAdmin).  
All scripts aim to be **POSIX-friendly**, include **safety checks**, and print **clear output**.

> Created: 21.07.2025

## Contents

- `scripts/add_user.sh` – create a local user safely (optional sudo).
- `scripts/disk_usage.sh` – disk usage summary and top space hogs.
- `scripts/backup_home.sh` – tar.gz backups of home directories (excludes caches).
- `scripts/log_cleanup.sh` – journal cleanup and package cache pruning.
- `scripts/sys_health.sh` – quick system health report.
- `scripts/service_status.sh` – check service states; list failed units.
- `scripts/firewall_config.sh` – opinionated UFW hardening (idempotent).
- `scripts/ssh_hardening.sh` – backup & harden sshd_config with prompts.
- `scripts/net_diag.sh` – quick network diagnostics (IP, DNS, routes, pings).

## Quick start

```bash
git clone <your-fork-url> linux-admin-scripts
cd linux-admin-scripts
chmod +x scripts/*.sh
```

Run any script with `-h` to see help.

## Examples

```bash
sudo ./scripts/add_user.sh -u deploy -s
sudo ./scripts/backup_home.sh -u kamran -o /backups
sudo ./scripts/firewall_config.sh --enable --allow-ssh
sudo ./scripts/ssh_hardening.sh --disable-root --disable-passwords
./scripts/sys_health.sh
```

## Notes

- Scripts that modify system state require `sudo`.
- Every script creates a dated backup of config files it touches (where applicable).
- Tested on Debian/Ubuntu-based distros (CloudLinux-/RHEL-based may need minor tweaks).

### Script list

- `scripts/add_user.sh`
- `scripts/backup_home.sh`
- `scripts/disk_usage.sh`
- `scripts/firewall_config.sh`
- `scripts/log_cleanup.sh`
- `scripts/net_diag.sh`
- `scripts/service_status.sh`
- `scripts/ssh_hardening.sh`
- `scripts/sys_health.sh`
