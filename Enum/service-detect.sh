#!/bin/bash
# Service Detection Script
# Identify services running on open ports

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo -e "${GREEN}Service Detection${NC}"
    echo "Usage: $0 <target> [options]"
    echo ""
    echo "Options:"
    echo "  -t, --target   Target IP or hostname (required)"
    echo "  -p, --ports   Specific ports to check"
    echo "  -o, --output  Output file"
    echo "  -h, --help    Show this help"
    echo ""
    echo "Example:"
    echo "  $0 10.10.10.10"
    echo "  $0 10.10.10.10 -p 22,80,443"
}

get_banner() {
    local target="$1"
    local port="$2"
    local timeout="${3:-2}"

    # Try to get service banner
    timeout "$timeout" bash -c "echo QUIT | nc -w 1 $target $port 2>/dev/null" || \
    timeout "$timeout" bash -c "echo | nc -w 1 $target $port 2>/dev/null" || \
    timeout "$timeout" bash -c "HEAD / HTTP/1.0\\r\\n\\r\\n | nc -w 1 $target $port 2>/dev/null"
}

identify_service() {
    local port="$1"
    local banner="$2"

    # Common service mappings
    case $port in
        21)
            if echo "$banner" | grep -iq "220"; then echo "FTP"; fi
            ;;
        22)
            if echo "$banner" | grep -iq "SSH"; then echo "SSH"; fi
            ;;
        23)
            echo "Telnet"
            ;;
        25|587|465)
            if echo "$banner" | grep -iq "220"; then echo "SMTP"; fi
            ;;
        53)
            echo "DNS"
            ;;
        80)
            if echo "$banner" | grep -iq "HTTP"; then echo "HTTP"; fi
            ;;
        110)
            if echo "$banner" | grep -iq "POP"; then echo "POP3"; fi
            ;;
        143)
            if echo "$banner" | grep -iq "IMAP"; then echo "IMAP"; fi
            ;;
        443)
            if echo "$banner" | grep -iq "HTTP"; then echo "HTTPS"; fi
            ;;
        445)
            echo "SMB"
            ;;
        3306)
            if echo "$banner" | grep -iq "MySQL"; then echo "MySQL"; fi
            ;;
        3389)
            echo "RDP"
            ;;
        5432)
            if echo "$banner" | grep -iq "PostgreSQL"; then echo "PostgreSQL"; fi
            ;;
        5900)
            if echo "$banner" | grep -iq "RFB"; then echo "VNC"; fi
            ;;
        8080|8443)
            if echo "$banner" | grep -iq "HTTP"; then echo "HTTP-Alt"; fi
            ;;
    esac
}

# Main
TARGET=""
PORTS=""
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

echo -e "${GREEN}[*] Service Detection for $TARGET${NC}"
echo "=============================================="

if [ -z "$PORTS" ]; then
    # Scan common ports
    PORTS="21 22 23 25 53 80 110 111 135 139 143 443 445 993 995 1723 3306 3389 5432 5900 8080 8443"
fi

for port in $PORTS; do
    echo -n "Port $port: "

    banner=$(get_banner "$TARGET" "$port" 1)

    if [ -n "$banner" ]; then
        service=$(identify_service "$port" "$banner")
        if [ -n "$service" ]; then
            echo -e "${GREEN}$service${NC}"
            echo "$banner" | head -3
        else
            echo -e "${YELLOW}Unknown (banner: ${banner:0:50})${NC}"
        fi
    else
        echo -e "${RED}Closed${NC}"
    fi
done

echo ""
echo -e "${GREEN}[*] Service detection complete${NC}"
