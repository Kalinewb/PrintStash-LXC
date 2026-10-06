# PrintStash-LXC

One-command Proxmox VE installer for [PrintStash](https://github.com/xiao-villamor/PrintStash).
Creates a Debian 13 LXC with Docker and runs PrintStash's official compose file.

Run as root on the Proxmox host:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Kalinewb/PrintStash-LXC/main/printstash-lxc.sh)"
```

Then open `http://<container-ip>:3000` and create the admin account.

## Options

Set environment variables before the command:

| Variable | Default | |
|---|---|---|
| `CTID` | next free ID | container ID |
| `CORES` / `RAM` / `DISK` | 2 / 2048 MB / 16 GB | resources |
| `STORAGE` | `local-lvm` | rootfs storage |
| `TEMPLATE_STORAGE` | `local` | template storage |
| `BRIDGE` | `vmbr0` | network bridge |
| `NET` | `dhcp` | e.g. `192.168.1.50/24,gw=192.168.1.1` |

## Update

```bash
pct exec <ctid> -- bash -c 'cd /opt/printstash && docker compose pull && docker compose up -d'
```

Unofficial; not affiliated with PrintStash. Script is MIT licensed.
