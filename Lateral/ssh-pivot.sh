#!/bin/bash
# SSH Pivoting Script
# Set up SSH tunnels for lateral movement

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo -e "${GREEN}SSH Pivoting Script${NC}"
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  local    <local_port> <target_ip> <target_port>  - Local port forward"
    echo "  remote   <remote_port> <target_ip> <target_port> - Remote port forward"
    echo "  dynamic  <local_port>                          - Dynamic SOCKS proxy"
    echo "  jump     <jump_host> <target_ip> <local_port>  - Jump host tunneling"
    echo "  socks    <local_port>                          - Start SOCKS proxy"
    echo ""
    echo "Example:"
    echo "  $0 local 8080 10.10.10.5 80"
    echo "  $0 dynamic 1080"
    echo "  $0 jump user@10.10.10.5 172.16.1.5 2222"
}

ssh_local() {
    local local_port="$1"
    local target_ip="$2"
    local target_port="$3"

    echo -e "${GREEN}[*] Setting up local port forward:${NC}"
    echo -e "  Local: localhost:$local_port -> $target_ip:$target_port"
    echo ""
    echo -e "${YELLOW}Command to run:${NC}"
    echo "  ssh -L $local_port:$target_ip:$target_port user@target"
    echo ""
    ssh -N -L "$local_port:$target_ip:$target_port" target 2>/dev/null &
    echo -e "${GREEN}[+] Port forward active on :$local_port${NC}"
}

ssh_remote() {
    local remote_port="$1"
    local target_ip="$2"
    local target_port="$3"

    echo -e "${GREEN}[*] Setting up remote port forward:${NC}"
    echo -e "  Remote: $target_ip:$remote_port -> localhost:$target_port"
    echo ""
    echo -e "${YELLOW}Command to run:${NC}"
    echo "  ssh -R $remote_port:localhost:$target_port user@target"
}

ssh_dynamic() {
    local local_port="$1"

    echo -e "${GREEN}[*] Setting up dynamic SOCKS proxy on :$local_port${NC}"
    echo -e "${YELLOW}Command to run:${NC}"
    echo "  ssh -D $local_port -N user@target"
}

ssh_jump() {
    local jump_host="$1"
    local target_ip="$2"
    local local_port="$3"

    echo -e "${GREEN}[*] Setting up jump host tunnel:${NC}"
    echo -e "  Via: $jump_host -> $target_ip"
    echo -e "  Local port: $local_port"
    echo ""
    echo -e "${YELLOW}Command to run:${NC}"
    echo "  ssh -J $jump_host -L $local_port:$target_ip:22 user@$target_ip"
}

# Main
CMD="$1"

case $CMD in
    local)
        ssh_local "$2" "$3" "$4"
        ;;
    remote)
        ssh_remote "$2" "$3" "$4"
        ;;
    dynamic)
        ssh_dynamic "$2"
        ;;
    jump)
        ssh_jump "$2" "$3" "$4"
        ;;
    socks)
        ssh_dynamic "$2"
        ;;
    -h|--help|help|*)
        usage
        ;;
esac
