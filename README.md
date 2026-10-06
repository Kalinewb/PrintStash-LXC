# PrintStash-LXC

One-command Proxmox VE installer for [PrintStash](https://github.com/xiao-villamor/PrintStash).
Creates a Debian 13 LXC with Docker and runs PrintStash's official compose file.

Run as root on the Proxmox host:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Kalinewb/PrintStash-LXC/main/ct/printstash.sh)"
```

Then open `http://<container-ip>:3000` and create the admin account.

## Options

The installer uses the standard [community-scripts](https://github.com/community-scripts/core) menu (default or advanced settings, storage, bridge, static IP, etc.). Defaults: 2 CPU, 2 GB RAM, 16 GB disk, unprivileged Debian 13.

## Update

From the Proxmox host:

```bash
pct exec <ctid> -- bash -c 'cd /opt/printstash && docker compose pull && docker compose up -d'
```

Unofficial; not affiliated with PrintStash. Script is MIT licensed.
