#!/bin/bash
# Shodan Reconnaissance Script
# Gather information about targets using Shodan API

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SHODAN_API_KEY="${SHODAN_API_KEY:-}"

usage() {
    echo -e "${GREEN}Shodan Reconnaissance${NC}"
    echo "Usage: $0 <target> [options]"
    echo ""
    echo "Options:"
    echo "  -i, --ip         Target IP address"
    echo "  -h, --host      Target hostname"
    echo "  -n, --network   Target network (CIDR)"
    echo "  -s, --search    Search Shodan"
    echo "  -o, --output    Output file"
    echo "  -h, --help      Show this help"
    echo ""
    echo "Environment Variables:"
    echo "  SHODAN_API_KEY  Your Shodan API Key"
    echo ""
    echo "Example:"
    echo "  SHODAN_API_KEY=xxx $0 1.1.1.1 -i"
    echo "  SHODAN_API_KEY=xxx $0 apache -s"
}

get_host() {
    local ip="$1"
    local output="${2:-}"

    if [ -z "$SHODAN_API_KEY" ]; then
        echo -e "${RED}[!] Shodan API key not set${NC}"
        echo -e "${YELLOW}Set SHODAN_API_KEY environment variable${NC}"
        return 1
    fi

    echo -e "${GREEN}[*] Getting Shodan data for IP: $ip${NC}"

    curl -s "https://api.shodan.io/shodan/host/${ip}?key=${SHODAN_API_KEY}" | \
        tee "${output:-/dev/null}" 2>/dev/null | python3 -m json.tool 2>/dev/null || \
        echo -e "${RED}[!] Failed to get host data or jq/json tool missing${NC}"
}

search_shodan() {
    local query="$1"
    local output="${2:-}"

    if [ -z "$SHODAN_API_KEY" ]; then
        echo -e "${RED}[!] Shodan API key not set${NC}"
        return 1
    fi

    echo -e "${GREEN}[*] Searching Shodan for: $query${NC}"

    curl -s "https://api.shodan.io/shodan/host/search?key=${SHODAN_API_KEY}&query=${query}" | \
        tee "${output:-/dev/null}" 2>/dev/null | python3 -m json.tool 2>/dev/null
}

get_hostnames() {
    local ip="$1"
    local output="${2:-}"

    if [ -z "$SHODAN_API_KEY" ]; then
        echo -e "${RED}[!] Shodan API key not set${NC}"
        return 1
    fi

    echo -e "${GREEN}[*] Getting hostnames for IP: $ip${NC}"

    curl -s "https://api.shodan.io/shodan/host/${ip}/hostnames?key=${SHODAN_API_KEY}" | \
        tee "${output:-/dev/null}" 2>/dev/null
}

dns_lookup() {
    local hostname="$1"
    local output="${2:-}"

    if [ -z "$SHODAN_API_KEY" ]; then
        echo -e "${RED}[!] Shodan API key not set${NC}"
        return 1
    fi

    echo -e "${GREEN}[*] DNS lookup for: $hostname${NC}"

    curl -s "https://api.shodan.io/dns/resolve?hostnames=${hostname}&key=${SHODAN_API_KEY}" | \
        tee "${output:-/dev/null}" 2>/dev/null
}

reverse_dns() {
    local ip="$1"
    local output="${2:-}"

    if [ -z "$SHODAN_API_KEY" ]; then
        echo -e "${RED}[!] Shodan API key not set${NC}"
        return 1
    fi

    echo -e "${GREEN}[*] Reverse DNS for IP: $ip${NC}"

    curl -s "https://api.shodan.io/dns/reverse?ips=${ip}&key=${SHODAN_API_KEY}" | \
        tee "${output:-/dev/null}" 2>/dev/null
}

exploit_search() {
    local query="$1"
    local output="${2:-}"

    if [ -z "$SHODAN_API_KEY" ]; then
        echo -e "${RED}[!] Shodan API key not set${NC}"
        return 1
    fi

    echo -e "${GREEN}[*] Searching exploits for: $query${NC}"

    curl -s "https://api.shodan.io/shodan/exploits?key=${SHODAN_API_KEY}&q=${query}" | \
        tee "${output:-/dev/null}" 2>/dev/null | python3 -m json.tool 2>/dev/null
}

# Main
TARGET=""
MODE="host"
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--ip)
            MODE="host"
            TARGET="$2"
            shift 2
            ;;
        -h|--host)
            MODE="dns"
            TARGET="$2"
            shift 2
            ;;
        -n|--network)
            MODE="host"
            TARGET="$2"
            shift 2
            ;;
        -s|--search)
            MODE="search"
            TARGET="$2"
            shift 2
            ;;
        -e|--exploit)
            MODE="exploit"
            TARGET="$2"
            shift 2
            ;;
        --hostnames)
            MODE="hostnames"
            TARGET="$2"
            shift 2
            ;;
        --reverse)
            MODE="reverse"
            TARGET="$2"
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

case $MODE in
    host)
        get_host "$TARGET" "$OUTPUT"
        ;;
    search)
        search_shodan "$TARGET" "$OUTPUT"
        ;;
    dns)
        dns_lookup "$TARGET" "$OUTPUT"
        ;;
    hostnames)
        get_hostnames "$TARGET" "$OUTPUT"
        ;;
    reverse)
        reverse_dns "$TARGET" "$OUTPUT"
        ;;
    exploit)
        exploit_search "$TARGET" "$OUTPUT"
        ;;
esac
