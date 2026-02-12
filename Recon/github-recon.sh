#!/bin/bash
# GitHub Reconnaissance Script
# Find sensitive information in GitHub repositories

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

GITHUB_TOKEN="${GITHUB_TOKEN:-}"

usage() {
    echo -e "${GREEN}GitHub Reconnaissance${NC}"
    echo "Usage: $0 <organization|user|keyword> [options]"
    echo ""
    echo "Options:"
    echo "  -o, --org        Search organization repositories"
    echo "  -u, --user       Search user repositories"
    echo "  -k, --keyword    Search by keyword"
    echo "  -s, --secrets    Search for secrets/API keys"
    echo "  -c, --code       Search code"
    echo "  --dorks          Show GitHub dorks"
    echo "  -h, --help       Show this help"
    echo ""
    echo "Environment Variables:"
    echo "  GITHUB_TOKEN     Your GitHub Personal Access Token"
    echo ""
    echo "Example:"
    echo "  GITHUB_TOKEN=xxx $0 company-name -o"
    echo "  $0 api_key -s"
}

search_code() {
    local query="$1"
    local output="${2:-}"

    echo -e "${GREEN}[*] Searching GitHub for: $query${NC}"

    if [ -n "$GITHUB_TOKEN" ]; then
        curl -s -H "Authorization: token $GITHUB_TOKEN" \
            "https://api.github.com/search/code?q=${query}" | tee "${output:-/dev/null}" 2>/dev/null
    else
        echo -e "${YELLOW}[!] No GitHub token set. Using public search...${NC}"
        curl -s "https://github.com/search?q=${query}&type=code" | \
            grep -o 'href="/[^"]*"' | grep -v '/search' | head -20
    fi
}

search_repos() {
    local query="$1"
    local output="${2:-}"

    echo -e "${GREEN}[*] Searching repositories for: $query${NC}"

    if [ -n "$GITHUB_TOKEN" ]; then
        curl -s -H "Authorization: token $GITHUB_TOKEN" \
            "https://api.github.com/search/repositories?q=${query}" | tee "${output:-/dev/null}" 2>/dev/null
    else
        curl -s "https://github.com/search?q=${query}&type=repositories" | \
            grep -o 'href="/[^"]*"' | grep -v '/search' | head -20
    fi
}

search_secrets() {
    local query="$1"
    local output="${2:-}"

    echo -e "${RED}[*] WARNING: Searching for secrets! Use responsibly!${NC}"
    echo -e "${GREEN}[*] Searching for: $query${NC}"

    if [ -n "$GITHUB_TOKEN" ]; then
        curl -s -H "Authorization: token $GITHUB_TOKEN" \
            "https://api.github.com/search/code?q=${query}+in:file" | tee "${output:-/dev/null}" 2>/dev/null
    else
        curl -s "https://github.com/search?q=${query}+in:file&type=code" | \
            grep -o 'href="/[^"]*"' | head -10
    fi
}

list_org_repos() {
    local org="$1"
    local output="${2:-}"

    echo -e "${GREEN}[*] Listing repositories for: $org${NC}"

    if [ -n "$GITHUB_TOKEN" ]; then
        curl -s -H "Authorization: token $GITHUB_TOKEN" \
            "https://api.github.com/orgs/${org}/repos?per_page=100" | \
            jq -r '.[] | "\(.name)|\(.html_url)|\(.description)|\(.language)"' | tee "${output:-/dev/null}" 2>/dev/null
    else
        curl -s "https://github.com/${org}?tab=repositories" | \
            grep -o 'href="/[^"]*/[^"]*"' | grep '/$' | head -20
    fi
}

show_dorks() {
    echo -e "${GREEN}GitHub Dorks for Reconnaissance:${NC}"
    echo ""
    echo "API Keys:"
    echo '  extension:env API_KEY'
    echo '  extension:env AWS_SECRET'
    echo '  extension:json api_key'
    echo ""
    echo "Credentials:"
    echo '  filename:.git-credentials'
    echo '  filename:.env DB_PASSWORD'
    echo '  password= in:file'
    echo ""
    echo "Private Keys:"
    echo '  -----BEGIN RSA PRIVATE KEY-----'
    echo '  -----BEGIN PRIVATE KEY-----'
    echo ""
    echo "Configuration Files:"
    echo '  filename:config.js password'
    echo '  filename:database.yml'
    echo '  filename:wp-config.php'
    echo ""
    echo "Token Patterns:"
    echo '  github_token in:file'
    echo '  aws_access_key in:file'
}

# Main
TARGET=""
MODE="code"
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--org)
            MODE="org"
            TARGET="$2"
            shift 2
            ;;
        -u|--user)
            MODE="user"
            TARGET="$2"
            shift 2
            ;;
        -k|--keyword)
            MODE="code"
            TARGET="$2"
            shift 2
            ;;
        -s|--secrets)
            MODE="secrets"
            TARGET="$2"
            shift 2
            ;;
        -c|--code)
            MODE="code"
            TARGET="$2"
            shift 2
            ;;
        --dorks)
            show_dorks
            exit 0
            ;;
        -o=*|--org=*)
            MODE="org"
            TARGET="${1#*=}"
            shift
            ;;
        -u=*|--user=*)
            MODE="user"
            TARGET="${1#*=}"
            shift
            ;;
        -k=*|--keyword=*)
            MODE="code"
            TARGET="${1#*=}"
            shift
            ;;
        -s=*|--secrets=*)
            MODE="secrets"
            TARGET="${1#*=}"
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
    org)
        list_org_repos "$TARGET" "$OUTPUT"
        ;;
    user)
        list_org_repos "$TARGET" "$OUTPUT"
        ;;
    code)
        search_code "$TARGET" "$OUTPUT"
        ;;
    secrets)
        search_secrets "$TARGET" "$OUTPUT"
        ;;
esac
