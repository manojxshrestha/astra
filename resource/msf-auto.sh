#!/bin/bash
# Metasploit Resource Runner
# Automates Metasploit auxiliary modules and exploitation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOURCE_DIR="${SCRIPT_DIR}/resource"

banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║         METASPLOIT RESOURCE AUTOMATION                   ║
║              pwnthebox Framework                        ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# List available resource files
list_resources() {
    echo -e "${CYAN}Available Resource Files:${NC}"
    echo ""
    i=1
    for file in "$RESOURCE_DIR"/*.rc; do
        if [[ -f "$file" ]]; then
            name=$(basename "$file" .rc)
            desc=$(head -5 "$file" 2>/dev/null | grep -E "^#|resource" | head -1 || echo "Metasploit resource file")
            echo -e "${GREEN}$i)${NC} $name"
            ((i++))
        fi
    done
}

# Run single resource file
run_resource() {
    local resource="$1"
    local target="$2"
    local port="$3"
    
    if [[ ! -f "$resource" ]]; then
        echo -e "${RED}[!] Resource file not found: $resource${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[*] Running resource: $(basename "$resource")${NC}"
    echo -e "${BLUE}[*] Target: ${target}:${port}${NC}"
    
    # Create temporary modified resource
    local tmp_resource=$(mktemp)
    sed "s|RHOST|$target|g; s|RPORT|$port|g" "$resource" > "$tmp_resource"
    
    # Run with msfconsole
    if command -v msfconsole &> /dev/null; then
        msfconsole -r "$tmp_resource" -q
    else
        echo -e "${RED}[!] Metasploit not found${NC}"
    fi
    
    rm -f "$tmp_resource"
}

# Run all resources against target
mass_run() {
    local target="$1"
    local port="${2:-80}"
    
    echo -e "${YELLOW}[*] Mass running all resources against $target:$port${NC}"
    
    for file in "$RESOURCE_DIR"/*.rc; do
        if [[ -f "$file" ]]; then
            name=$(basename "$file" .rc)
            echo -e "${BLUE}[*] Running: $name${NC}"
            run_resource "$file" "$target" "$port"
        fi
    done
}

# Create custom resource from template
create_resource() {
    local name="$1"
    local target="$2"
    local port="$3"
    local module="$4"
    
    cat > "${RESOURCE_DIR}/${name}.rc" << EOF
# Custom Resource File
# Target: $target:$port
# Module: $module

use $module
set RHOSTS $target
set RPORT $port
set THREADS 10
run
EOF
    
    echo -e "${GREEN}[+] Created: ${RESOURCE_DIR}/${name}.rc${NC}"
}

# Show usage
usage() {
    cat << 'EOF'
USAGE:
    ./msf-automation.sh [OPTIONS]

OPTIONS:
    -l, --list              List available resource files
    -r, --run FILE          Run specific resource file
    -t, --target HOST       Target IP/hostname
    -p, --port PORT         Target port [default: 80]
    -m, --mass HOST         Run all resources against target
    -c, --create NAME       Create custom resource
    --module MODULE         Module for custom resource
    -h, --help              Show this help

EXAMPLES:
    # List all resources
    ./msf-automation.sh --list

    # Run specific resource
    ./msf-automation.sh --run 445-smb.rc --target 192.168.1.1

    # Run all against target
    ./msf-automation.sh --mass 192.168.1.1

    # Create custom resource
    ./msf-automation.sh --create myscan --target 10.10.10.1 --port 443 --module auxiliary/scanner/http/title

EOF
}

main() {
    local action="menu"
    local target=""
    local port="80"
    local resource=""
    local name=""
    local module=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -l|--list) action="list" ;;
            -r|--run) resource="$2"; shift ;;
            -t|--target) target="$2"; shift ;;
            -p|--port) port="$2"; shift ;;
            -m|--mass) target="$2"; action="mass" ;;
            -c|--create) name="$2"; shift ;;
            --module) module="$2"; shift ;;
            -h|--help) action="help" ;;
            *) target="$1" ;;
        esac
        shift
    done
    
    banner
    
    case "$action" in
        list)
            list_resources
            ;;
        run)
            if [[ -n "$target" ]]; then
                run_resource "$resource" "$target" "$port"
            else
                echo -e "${RED}[!] Target required${NC}"
            fi
            ;;
        mass)
            if [[ -n "$target" ]]; then
                mass_run "$target" "$port"
            else
                echo -e "${RED}[!] Target required${NC}"
            fi
            ;;
        create)
            if [[ -n "$name" && -n "$target" && -n "$module" ]]; then
                create_resource "$name" "$target" "$port" "$module"
            else
                echo -e "${RED}[!] Name, target, and module required${NC}"
            fi
            ;;
        help)
            usage
            ;;
        *)
            list_resources
            echo ""
            echo -e "${YELLOW}[*] Use --help for options${NC}"
            ;;
    esac
}

main "$@"
