#!/bin/bash
# Socat Pivoting Script
# Advanced pivoting with socat

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo -e "${GREEN}Socat Pivoting Script${NC}"
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  forward   <local_port> <target_ip> <target_port>  - Port forward"
    echo "  relay     <local_port> <target_ip> <target_port>  - Relay through pivot"
    echo "  socks     <local_port>                             - SOCKS proxy"
    echo "  exec      <target_ip> <command>                    - Remote exec"
    echo "  udp       <local_port> <target_ip> <target_port>  - UDP forward"
    echo ""
    echo "Example:"
    echo "  $0 forward 8080 10.10.10.5 80"
    echo "  $0 socks 1080"
    echo "  $0 relay 9000 10.10.10.5 22"
}

check_socat() {
    if ! command -v socat >/dev/null 2>&1; then
        echo -e "${RED}[!] socat not installed${NC}"
        echo -e "${YELLOW}Install with: apt install socat${NC}"
        exit 1
    fi
}

port_forward() {
    local local_port="$1"
    local target_ip="$2"
    local target_port="$3"

    check_socat

    echo -e "${GREEN}[*] Port forward: localhost:$local_port -> $target_ip:$target_port${NC}"
    echo -e "${YELLOW}Running:${NC}"
    echo "  socat TCP-LISTEN:$local_port,fork TCP:$target_ip:$target_port"
    echo ""
    socat TCP-LISTEN:$local_port,fork TCP:$target_ip:$target_port &
    echo -e "${GREEN}[+] Forward active on :$local_port${NC}"
}

relay() {
    local local_port="$1"
    local target_ip="$2"
    local target_port="$3"

    check_socat

    echo -e "${GREEN}[*] Relay through pivot${NC}"
    echo -e "${YELLOW}Running:${NC}"
    echo "  socat TCP-LISTEN:$local_port,bind=127.0.0.1,fork,reuseaddr TCP:$target_ip:$target_port"
    socat TCP-LISTEN:$local_port,bind=127.0.0.1,fork,reuseaddr TCP:$target_ip:$target_port &
    echo -e "${GREEN}[+] Relay active on 127.0.0.1:$local_port${NC}"
}

socks_proxy() {
    local local_port="$1"

    check_socat

    echo -e "${GREEN}[*] SOCKS proxy on :$local_port${NC}"
    echo -e "${YELLOW}Running:${NC}"
    echo "  socat TCP-LISTEN:$local_port,fork SOCKS4A:localhost:socks.yahoo.com:80,socksport=$local_port"
    echo ""
    echo -e "${RED}[!] Note: SOCKS4A requires configuring proxy in /etc/proxychains4.conf${NC}"
}

udp_forward() {
    local local_port="$1"
    local target_ip="$2"
    local target_port="$3"

    check_socat

    echo -e "${GREEN}[*] UDP forward: localhost:$local_port -> $target_ip:$target_port${NC}"
    echo -e "${YELLOW}Running:${NC}"
    echo "  socat UDP-LISTEN:$local_port,fork UDP:$target_ip:$target_port"
    socat UDP-LISTEN:$local_port,fork UDP:$target_ip:$target_port &
    echo -e "${GREEN}[+] UDP forward active on :$local_port${NC}"
}

remote_exec() {
    local target_ip="$1"
    local command="$2"

    check_socat

    echo -e "${GREEN}[*] Remote exec via socat${NC}"
    echo -e "${YELLOW}Running:${NC}"
    echo "  echo '$command' | socat - TCP:$target_ip:4444"
}

# Main
CMD="$1"

case $CMD in
    forward)
        port_forward "$2" "$3" "$4"
        ;;
    relay)
        relay "$2" "$3" "$4"
        ;;
    socks)
        socks_proxy "$2"
        ;;
    udp)
        udp_forward "$2" "$3" "$4"
        ;;
    exec)
        remote_exec "$2" "$3"
        ;;
    -h|--help|help|*)
        usage
        ;;
esac
