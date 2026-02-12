#!/bin/bash
# Chisel Pivoting Script
# Fast HTTP/SOCKS proxy tool for pivoting

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CHISEL_BIN="${CHISEL_BIN:-./chisel}"

usage() {
    echo -e "${GREEN}Chisel Pivoting Script${NC}"
    echo "Usage: $0 <mode> [options]"
    echo ""
    echo "Modes:"
    echo "  server <port>                 - Start chisel server (on compromised host)"
    echo "  client <server> <local_port>  - Connect to server, forward local port"
    echo "  socks <server>                 - Create SOCKS proxy through server"
    echo "  reverse <server>               - Reverse connection to server"
    echo ""
    echo "Environment Variables:"
    echo "  CHISEL_BIN     Path to chisel binary (default: ./chisel)"
    echo ""
    echo "Download chisel:${NC}"
    echo "  https://github.com/jpillora/chisel/releases"
    echo ""
    echo "Example:"
    echo "  # On compromised host (server):"
    echo "  $0 server 8080"
    echo ""
    echo "  # From attacking machine:"
    echo "  $0 client 10.10.10.5:8080 8000"
    echo "  $0 socks 10.10.10.5:8080"
}

check_chisel() {
    if ! command -v chisel >/dev/null 2>&1 && [ ! -f "$CHISEL_BIN" ]; then
        echo -e "${RED}[!] chisel not found${NC}"
        echo -e "${YELLOW}Download from:${NC}"
        echo "  https://github.com/jpillora/chisel/releases"
        echo ""
        echo -e "${YELLOW}Linux (AMD64):${NC}"
        echo "  wget https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_amd64.gz"
        echo "  gunzip chisel_1.9.1_linux_amd64.gz && chmod +x chisel"
        exit 1
    fi
}

server_mode() {
    local port="${1:-8080}"

    check_chisel

    echo -e "${GREEN}[*] Starting Chisel SERVER on port $port${NC}"
    echo -e "${YELLOW}[*] Waiting for connections...${NC}"
    echo ""
    echo -e "${CYAN}From attacking machine, connect with:${NC}"
    echo "  chisel client $YOUR_IP:$port socks"
    echo ""

    if command -v chisel >/dev/null 2>&1; then
        chisel server --port "$port" --reverse
    else
        "$CHISEL_BIN" server --port "$port" --reverse
    fi
}

client_mode() {
    local server="$1"
    local local_port="$2"

    check_chisel

    echo -e "${GREEN}[*] Starting Chisel CLIENT${NC}"
    echo -e "  Server: $server"
    echo -e "  Local port: $local_port"
    echo ""

    if command -v chisel >/dev/null 2>&1; then
        chisel client "$server" "localhost:$local_port"
    else
        "$CHISEL_BIN" client "$server" "localhost:$local_port"
    fi
}

socks_mode() {
    local server="$1"

    check_chisel

    echo -e "${GREEN}[*] Starting SOCKS proxy through $server${NC}"
    echo -e "${YELLOW}[*] This will create a SOCKS5 proxy on localhost:1080${NC}"
    echo ""

    if command -v chisel >/dev/null 2>&1; then
        chisel client "$server" socks
    else
        "$CHISEL_BIN" client "$server" socks
    fi
}

reverse_mode() {
    local server="$1"

    check_chisel

    echo -e "${GREEN}[*] Starting REVERSE chisel client${NC}"
    echo -e "  Server: $server"
    echo ""

    if command -v chisel >/dev/null 2>&1; then
        chisel client --reverse "$server"
    else
        "$CHISEL_BIN" client --reverse "$server"
    fi
}

# Main
MODE="$1"

case $MODE in
    server)
        server_mode "$2"
        ;;
    client)
        client_mode "$2" "$3"
        ;;
    socks)
        socks_mode "$2"
        ;;
    reverse)
        reverse_mode "$2"
        ;;
    -h|--help|help|*)
        usage
        ;;
esac
