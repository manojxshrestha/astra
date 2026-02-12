#!/bin/bash
# Censys Reconnaissance Script
# Gather information about a target using Censys API

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

API_ID="${CENSYS_API_ID:-}"
API_SECRET="${CENSYS_API_SECRET:-}"

usage() {
    echo -e "${GREEN}Censys Reconnaissance${NC}"
    echo "Usage: $0 <target_ip|domain> [options]"
    echo ""
    echo "Options:"
    echo "  -i, --ip       Target IP address"
    echo "  -d, --domain   Target domain"
    echo "  -o, --output   Output file"
    echo "  -h, --help     Show this help"
    echo ""
    echo "Environment Variables:"
    echo "  CENSYS_API_ID     Your Censys API ID"
    echo "  CENSYS_API_SECRET Your Censys API Secret"
    echo ""
    echo "Example:"
    echo "  CENSYS_API_ID=xxx CENSYS_API_SECRET=yyy $0 1.1.1.1"
}

query_censys() {
    local query="$1"
    local output="${2:-}"

    if [ -z "$API_ID" ] || [ -z "$API_SECRET" ]; then
        echo -e "${RED}[!] Censys API credentials not set${NC}"
        echo -e "${YELLOW}Set CENSYS_API_ID and CENSYS_API_SECRET environment variables${NC}"
        return 1
    fi

    echo -e "${GREEN}[*] Querying Censys for: $query${NC}"

    # Search for IPv4 hosts
    if curl -s -u "$API_ID:$API_SECRET" \
        "https://censys.io/api/v1/search/ipv4" \
        -d "{\"query\": \"$query\"}" | tee "${output:-/dev/null}" 2>/dev/null; then
        echo -e "${GREEN}[+] Results saved to ${output:-stdout}${NC}"
    else
        echo -e "${RED}[!] Failed to query Censys${NC}"
    fi
}

get_host_details() {
    local ip="$1"
    local output="${2:-}"

    if [ -z "$API_ID" ] || [ -z "$API_SECRET" ]; then
        echo -e "${RED}[!] Censys API credentials not set${NC}"
        return 1
    fi

    echo -e "${GREEN}[*] Getting details for IP: $ip${NC}"

    curl -s -u "$API_ID:$API_SECRET" \
        "https://censys.io/api/v1/view/ipv4/$ip" | tee "${output:-/dev/null}" 2>/dev/null
}

search_certificates() {
    local domain="$1"
    local output="${2:-}"

    if [ -z "$API_ID" ] || [ -z "$API_SECRET" ]; then
        echo -e "${RED}[!] Censys API credentials not set${NC}"
        return 1
    fi

    echo -e "${GREEN}[*] Searching certificates for: $domain${NC}"

    curl -s -u "$API_ID:$API_SECRET" \
        "https://censys.io/api/v1/search/certificates" \
        -d "{\"query\": \"$domain\"}" | tee "${output:-/dev/null}" 2>/dev/null
}

# Main
TARGET=""
OUTPUT=""
MODE="search"

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--ip)
            MODE="view"
            TARGET="$2"
            shift 2
            ;;
        -d|--domain)
            MODE="cert"
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
    view)
        get_host_details "$TARGET" "$OUTPUT"
        ;;
    cert)
        search_certificates "$TARGET" "$OUTPUT"
        ;;
    search)
        query_censys "$TARGET" "$OUTPUT"
        ;;
esac
