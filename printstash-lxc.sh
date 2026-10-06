#!/usr/bin/env bash
# Run as root on a Proxmox VE host. Creates a Debian LXC running PrintStash in Docker.
# Override with env vars, e.g.: CTID=120 STORAGE=local-zfs BRIDGE=vmbr0 ./printstash-lxc.sh
set -euo pipefail

CTID="${CTID:-$(pvesh get /cluster/nextid)}"
HOSTNAME="${HOSTNAME_CT:-printstash}"
CORES="${CORES:-2}"
RAM="${RAM:-2048}"
DISK="${DISK:-16}"                 # GB; the library lives in /data inside Docker
STORAGE="${STORAGE:-local-lvm}"    # rootfs storage
TEMPLATE_STORAGE="${TEMPLATE_STORAGE:-local}"
BRIDGE="${BRIDGE:-vmbr0}"
NET="${NET:-dhcp}"                 # or e.g. 192.168.1.50/24,gw=192.168.1.1
COMPOSE_URL="https://raw.githubusercontent.com/xiao-villamor/PrintStash/main/docker-compose.yml"

[[ $EUID -eq 0 ]] && command -v pct >/dev/null || { echo "Run as root on a Proxmox host." >&2; exit 1; }

echo ">> Finding Debian 13 template"
pveam update >/dev/null
TEMPLATE="$(pveam available --section system | awk '/debian-13-standard/ {print $2}' | sort -V | tail -1)"
[[ -n "$TEMPLATE" ]] || { echo "No Debian 13 template found." >&2; exit 1; }
pveam list "$TEMPLATE_STORAGE" | grep -q "$TEMPLATE" || pveam download "$TEMPLATE_STORAGE" "$TEMPLATE"

echo ">> Creating CT $CTID"
pct create "$CTID" "$TEMPLATE_STORAGE:vztmpl/$TEMPLATE" \
  --hostname "$HOSTNAME" --cores "$CORES" --memory "$RAM" --swap 512 \
  --rootfs "$STORAGE:$DISK" --net0 "name=eth0,bridge=$BRIDGE,ip=$NET" \
  --features nesting=1,keyctl=1 --unprivileged 1 --onboot 1 --start 1

echo ">> Waiting for network"
for _ in $(seq 30); do
  pct exec "$CTID" -- getent hosts deb.debian.org >/dev/null 2>&1 && break
  sleep 2
done

echo ">> Installing Docker and PrintStash"
pct exec "$CTID" -- bash -euo pipefail -c "
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq curl ca-certificates docker.io docker-compose
  systemctl enable --now docker
  mkdir -p /opt/printstash && cd /opt/printstash
  curl -fsSL '$COMPOSE_URL' -o docker-compose.yml
  docker compose up -d || docker-compose up -d
"

IP="$(pct exec "$CTID" -- hostname -I | awk '{print $1}')"
echo
echo "PrintStash is starting at http://$IP:3000 (first pull may take a minute)."
echo "Shell: pct enter $CTID    Update: pct exec $CTID -- bash -c 'cd /opt/printstash && docker compose pull && docker compose up -d'"
