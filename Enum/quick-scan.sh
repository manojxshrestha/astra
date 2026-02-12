#!/bin/bash
# Quick Port Scanner - Fast TCP port discovery
# Uses multiple methods for quick port enumeration

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo -e "${GREEN}Quick Port Scanner${NC}"
    echo "Usage: $0 <target> [options]"
    echo ""
    echo "Options:"
    echo "  -t, --target   Target IP or hostname (required)"
    echo "  -p, --ports    Port range (default: 1-1000)"
    echo "  -T, --threads  Number of threads (default: 50)"
    echo "  -o, --output   Output file"
    echo "  -h, --help     Show this help"
    echo ""
    echo "Example:"
    echo "  $0 10.10.10.10"
    echo "  $0 10.10.10.10 -p 1-10000"
}

quick_scan() {
    local target="$1"
    local ports="$2"
    local threads="$3"
    local output="$4"

    echo -e "${GREEN}[*] Scanning $target ports $ports (threads: $threads)${NC}"

    if command -v nc >/dev/null 2>&1; then
        # Use netcat if available
        for port in $(seq $(echo $ports | cut -d- -f1) $(echo $ports | cut -d- -f2)); do
            timeout 0.5 nc -z -w 1 "$target" "$port" 2>/dev/null &
            if [ $((port % threads)) -eq 0 ]; then wait; fi
        done | tee "${output:-/dev/null}" 2>/dev/null
    elif command -v bash >/dev/null 2>&1; then
        # Use bash built-in
        for port in $(seq $(echo $ports | cut -d- -f1) $(echo $ports | cut -d- -f2)); do
            timeout 0.5 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null &
            if [ $((port % threads)) -eq 0 ]; then wait; fi
        done | tee "${output:-/dev/null}" 2>/dev/null
    else
        echo -e "${RED}[!] Neither nc nor bash available${NC}"
    fi
}

common_ports_scan() {
    local target="$1"
    local output="$2"

    local common_ports="21 22 23 25 53 80 110 111 135 139 143 443 445 993 995 1723 3306 3389 5432 5900 8080 8443"

    echo -e "${GREEN}[*] Scanning common ports on $target${NC}"

    for port in $common_ports; do
        timeout 0.5 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null && \
            echo -e "${GREEN}[+] Port $port is OPEN${NC}" &
    done
    wait

    echo ""
    echo -e "${GREEN}[*] Scan complete${NC}"
}

# Main
TARGET=""
PORTS="1-1000"
THREADS=50
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--target)
            TARGET="$2"
            shift 2
            ;;
        -p|--ports)
            PORTS="$2"
            shift 2
            ;;
        -T|--threads)
            THREADS="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            TARGET="$1"
            shift
            ;;
    esac
done

if [ -z "$TARGET" ]; then
    usage
    exit 1
fi

common_ports_scan "$TARGET" "$OUTPUT"
