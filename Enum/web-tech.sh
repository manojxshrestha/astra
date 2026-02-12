#!/bin/bash
# Web Technology Detection Script
# Identify web technologies (CMS, frameworks, servers)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo -e "${GREEN}Web Technology Detection${NC}"
    echo "Usage: $0 <url> [options]"
    echo ""
    echo "Options:"
    echo "  -u, --url      Target URL (required)"
    echo "  -o, --output   Output file"
    echo "  -h, --help     Show this help"
    echo ""
    echo "Example:"
    echo "  $0 http://10.10.10.10"
    echo "  $0 https://example.com"
}

get_headers() {
    local url="$1"
    curl -s -I -m 5 "$url" 2>/dev/null
}

get_content() {
    local url="$1"
    curl -s -m 5 "$url" 2>/dev/null | head -100
}

detect_server() {
    local headers="$1"

    if echo "$headers" | grep -iq "Server:"; then
        echo "$headers" | grep -i "Server:" | head -1
    fi
}

detect_tech() {
    local content="$1"

    # WordPress
    if echo "$content" | grep -iq "wp-content\|wp-includes\|wordpress"; then
        echo -e "${GREEN}[+] WordPress Detected${NC}"
    fi

    # Joomla
    if echo "$content" | grep -iq "option=com\|joomla"; then
        echo -e "${GREEN}[+] Joomla Detected${NC}"
    fi

    # Drupal
    if echo "$content" | grep -iq "drupal\|sites/default"; then
        echo -e "${GREEN}[+] Drupal Detected${NC}"
    fi

    # React
    if echo "$content" | grep -iq "react\|__NEXT_DATA"; then
        echo -e "${GREEN}[+] React Detected${NC}"
    fi

    # Angular
    if echo "$content" | grep -iq "angular"; then
        echo -e "${GREEN}[+] Angular Detected${NC}"
    fi

    # Vue.js
    if echo "$content" | grep -iq "vue\|__VUE__"; then
        echo -e "${GREEN}[+] Vue.js Detected${NC}"
    fi

    # jQuery
    if echo "$content" | grep -iq "jquery"; then
        echo -e "${YELLOW}[!] jQuery Detected${NC}"
    fi

    # Bootstrap
    if echo "$content" | grep -iq "bootstrap"; then
        echo -e "${YELLOW}[!] Bootstrap Detected${NC}"
    fi

    # Apache
    if echo "$headers" | grep -iq "Apache"; then
        echo -e "${YELLOW}[!] Apache Server Detected${NC}"
    fi

    # Nginx
    if echo "$headers" | grep -iq "Nginx"; then
        echo -e "${YELLOW}[!] Nginx Server Detected${NC}"
    fi

    # IIS
    if echo "$headers" | grep -iq "IIS\|ASP.NET"; then
        echo -e "${YELLOW}[!] IIS/ASP.NET Detected${NC}"
    fi

    # PHP
    if echo "$headers" | grep -iq "PHP"; then
        echo -e "${YELLOW}[!] PHP Detected${NC}"
    fi

    # Python
    if echo "$headers" | grep -iq "Python\|WSGI"; then
        echo -e "${YELLOW}[!] Python Detected${NC}"
    fi

    # Ruby on Rails
    if echo "$content" | grep -iq "rails\|rack"; then
        echo -e "${YELLOW}[!] Ruby on Rails Detected${NC}"
    fi

    # Cloudflare
    if echo "$headers" | grep -iq "cloudflare"; then
        echo -e "${CYAN}[*] Cloudflare Detected${NC}"
    fi

    # AWS
    if echo "$headers" | grep -iq "AWS\|Amazon"; then
        echo -e "${CYAN}[*] AWS/Amazon Detected${NC}"
    fi
}

detect_cookies() {
    local headers="$1"

    if echo "$headers" | grep -iq "Set-Cookie:"; then
        echo -e "${YELLOW}[*] Cookies detected:${NC}"
        echo "$headers" | grep -i "Set-Cookie:" | head -5
    fi
}

detect_security() {
    local headers="$1"

    # Security headers
    echo -e "${GREEN}[*] Security Headers:${NC}"

    if echo "$headers" | grep -iq "Strict-Transport-Security"; then
        echo -e "  ${GREEN}HSTS: Enabled${NC}"
    else
        echo -e "  ${RED}HSTS: Missing${NC}"
    fi

    if echo "$headers" | grep -iq "X-Frame-Options"; then
        echo -e "  ${GREEN}X-Frame-Options: Present${NC}"
    else
        echo -e "  ${RED}X-Frame-Options: Missing${NC}"
    fi

    if echo "$headers" | grep -iq "X-Content-Type-Options"; then
        echo -e "  ${GREEN}X-Content-Type-Options: Present${NC}"
    else
        echo -e "  ${RED}X-Content-Type-Options: Missing${NC}"
    fi

    if echo "$headers" | grep -iq "Content-Security-Policy"; then
        echo -e "  ${GREEN}CSP: Present${NC}"
    else
        echo -e "  ${RED}CSP: Missing${NC}"
    fi
}

# Main
URL=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--url)
            URL="$2"
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
            URL="$1"
            shift
            ;;
    esac
done

if [ -z "$URL" ]; then
    usage
    exit 1
fi

echo -e "${GREEN}[*] Web Technology Detection for $URL${NC}"
echo "=============================================="
echo ""

headers=$(get_headers "$URL")
content=$(get_content "$URL")

echo -e "${GREEN}[*] Server Information:${NC}"
detect_server "$headers"
echo ""

echo -e "${GREEN}[*] Security Headers:${NC}"
detect_security "$headers"
echo ""

echo -e "${GREEN}[*] Technologies Detected:${NC}"
detect_tech "$content"
echo ""

echo -e "${GREEN}[*] Cookie Analysis:${NC}"
detect_cookies "$headers"
echo ""

echo -e "${GREEN}[*] Technology detection complete${NC}"
