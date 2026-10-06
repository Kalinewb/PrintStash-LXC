#!/usr/bin/env bash

# Copyright (c) 2026 Kalinewb
# License: MIT | https://github.com/Kalinewb/PrintStash-LXC/raw/main/LICENSE
# Source: https://github.com/xiao-villamor/PrintStash

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

setup_docker

msg_info "Setting up PrintStash"
mkdir -p /opt/printstash
curl -fsSL https://raw.githubusercontent.com/xiao-villamor/PrintStash/main/docker-compose.yml -o /opt/printstash/docker-compose.yml
msg_ok "Downloaded Compose file"

msg_info "Starting PrintStash (pulling image)"
cd /opt/printstash || exit
$STD docker compose up -d
msg_ok "Started PrintStash"

motd_ssh
customize
cleanup_lxc
