#!/bin/bash
# Wayback Machine Recon Script
# Find historical versions and information about targets

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo -e "${GREEN}Wayback Machine Reconnaissance${NC}"
    echo "Usage: $0 <domain> [options]"
    echo ""
    echo "Options:"
    echo "  -d, --domain   Target domain (required)"
    echo "  -s, --snapshots  List all snapshots"
    echo "  -u, --urls       Find URLs from Wayback"
    echo "  -e, --extract    Extract subdomains from archives"
    echo "  -o, --output     Output file"
    echo "  -h, --help       Show this help"
    echo ""
    echo "Example:"
    echo "  $0 example.com -s"
    echo "  $0 example.com -e"
}

list_snapshots() {
    local domain="$1"
    local output="${2:-}"

    echo -e "${GREEN}[*] Getting snapshots for: $domain${NC}"

    curl -s "http://web.archive.org/cdx/search/cdx?url=*.${domain}&output=json" 2>/dev/null | \
        jq -r '.[1:] | map(.[2]) | unique | .[]' | tee "${output:-/dev/null}" 2>/dev/null || \
        echo -e "${RED}[!] Failed to get snapshots${NC}"
}

find_urls() {
    local domain="$1"
    local output="${2:-}"

    echo -e "${GREEN}[*] Finding URLs for: $domain${NC}"

    curl -s "http://web.archive.org/cdx/search/cdx?url=${domain}/*&output=json&fl=original" 2>/dev/null | \
        jq -r '.[]' | sort -u | tee "${output:-/dev/null}" 2>/dev/null || \
        echo -e "${RED}[!] Failed to find URLs${NC}"
}

extract_subdomains() {
    local domain="$1"
    local output="${2:-}"

    echo -e "${GREEN}[*] Extracting subdomains from: $domain${NC}"

    curl -s "http://web.archive.org/cdx/search/cdx?url=*.${domain}&output=json&fl=original" 2>/dev/null | \
        jq -r '.[1:] | map(select(. != null)) | map(.[2]) | map(select(contains("."))) | map(gsub(".*://"; "")) | map(gsub("/.*"; "")) | unique | .[]' | \
        grep -E "^[a-zA-Z0-9].*${domain}$" | tee "${output:-/dev/null}" 2>/dev/null || \
        echo -e "${RED}[!] Failed to extract subdomains${NC}"
}

get_changes() {
    local domain="$1"
    local output="${2:-}"

    echo -e "${GREEN}[*] Finding changes for: $domain${NC}"

    curl -s "http://web.archive.org/cdx/search/cdx?url=${domain}&output=json&fl=timestamp,original&filter=statuscode:200" 2>/dev/null | \
        jq -r '.[] | "\(.[0]) \(.[1])"' | head -20 | tee "${output:-/dev/null}" 2>/dev/null || \
        echo -e "${RED}[!] Failed to get changes${NC}"
}

# Main
DOMAIN=""
MODE="snapshots"
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--domain)
            DOMAIN="$2"
            shift 2
            ;;
        -s|--snapshots)
            MODE="snapshots"
            shift
            ;;
        -u|--urls)
            MODE="urls"
            shift
            ;;
        -e|--extract)
            MODE="extract"
            shift
            ;;
        -c|--changes)
            MODE="changes"
            shift
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
            DOMAIN="$1"
            shift
            ;;
    esac
done

if [ -z "$DOMAIN" ]; then
    usage
    exit 1
fi

case $MODE in
    snapshots)
        list_snapshots "$DOMAIN" "$OUTPUT"
        ;;
    urls)
        find_urls "$DOMAIN" "$OUTPUT"
        ;;
    extract)
        extract_subdomains "$DOMAIN" "$OUTPUT"
        ;;
    changes)
        get_changes "$DOMAIN" "$OUTPUT"
        ;;
esac
