#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
LIGHT_CYAN='\033[1;36m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
NC='\033[0m'

BOLD='\033[1m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'

SED_RED="s,.RED.,${RED},g"
SED_GREEN="s,.GREEN.,${GREEN},g"
SED_YELLOW="s,.YELLOW.,${YELLOW},g"
SED_BLUE="s,.BLUE.,${BLUE},g"
SED_CYAN="s,.CYAN.,${CYAN},g"
SED_MAGENTA="s,.MAGENTA.,${MAGENTA},g"
SED_LIGHT_CYAN="s,.LIGHTCYAN.,${LIGHT_CYAN},g"
SED_LIGHT_RED="s,.LIGHTRED.,${LIGHT_RED},g"
SED_LIGHT_GREEN="s,.LIGHTGREEN.,${LIGHT_GREEN},g"

SEPARATOR="═══════════════════════════════════════════════════════════════════"

OUTPUT_FORMAT="text"
STEALTH_MODE=false
VERBOSE=false
QUICK_MODE=false
TIMEOUT_VALUE=150

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

print_banner() {
    if [[ "$STEALTH_MODE" == "true" ]]; then
        return
    fi
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║           LINUX PRIVILEGE ESCALATION CHECKER                      ║
║              PEASS-ng Inspired Professional Edition               ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_title() {
    local title="$1"
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        return
    fi
    echo ""
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo -e "${CYAN}${SEPARATOR}${NC}"
    fi
    echo -e "${CYAN}  ${title}${NC}"
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo -e "${CYAN}${SEPARATOR}${NC}"
    fi
    echo ""
}

print_subtitle() {
    local subtitle="$1"
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        return
    fi
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo -e "${BLUE}  ${subtitle}${NC}"
    else
        echo "  ${subtitle}"
    fi
}

print_info() {
    local message="$1"
    local color="${2:-$BLUE}"
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        return
    fi
    
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo -e "${color}[*] ${NC}${message}"
    else
        echo "[*] ${message}"
    fi
}

print_good() {
    local message="$1"
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        return
    fi
    
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo -e "${GREEN}[+] ${NC}${message}"
    else
        echo "[+] ${message}"
    fi
}

print_warn() {
    local message="$1"
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        return
    fi
    
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo -e "${YELLOW}[!] ${NC}${message}"
    else
        echo "[!] ${message}"
    fi
}

print_critical() {
    local message="$1"
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        return
    fi
    
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo -e "${RED}[CRITICAL] ${NC}${message}"
    else
        echo "[CRITICAL] ${message}"
    fi
}

print_high() {
    local message="$1"
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        return
    fi
    
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo -e "${LIGHT_RED}[HIGH] ${NC}${message}"
    else
        echo "[HIGH] ${message}"
    fi
}

print_medium() {
    local message="$1"
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        return
    fi
    
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo -e "${YELLOW}[MEDIUM] ${NC}${message}"
    else
        echo "[MEDIUM] ${message}"
    fi
}

print_low() {
    local message="$1"
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        return
    fi
    
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo -e "${BLUE}[LOW] ${NC}${message}"
    else
        echo "[LOW] ${message}"
    fi
}

print_link() {
    local message="$1"
    local url="$2"
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        return
    fi
    
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo -e "${CYAN}${message}${NC}: ${LIGHT_CYAN}${url}${NC}"
    else
        echo "${message}: ${url}"
    fi
}

print_command() {
    local command="$1"
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        return
    fi
    
    if [[ "$STEALTH_MODE" == "false" ]]; then
        echo -e "${MAGENTA}\$ ${command}${NC}"
    else
        echo "$ ${command}"
    fi
}

print_result() {
    local result="$1"
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        return
    fi
    
    echo -e "${LIGHT_CYAN}${result}${NC}"
}

check_command() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}

timeout_command() {
    local cmd="$1"
    local timeout="${2:-$TIMEOUT_VALUE}"
    
    if [[ "$QUICK_MODE" == "true" ]]; then
        timeout 5 bash -c "$cmd" 2>/dev/null
    else
        timeout "$timeout" bash -c "$cmd" 2>/dev/null
    fi
}

get_os_info() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$NAME $VERSION"
    elif [[ -f /etc/lsb-release ]]; then
        source /etc/lsb-release
        echo "$DISTRIB_DESCRIPTION"
    else
        uname -a
    fi
}

get_kernel() {
    uname -r
}

get_arch() {
    uname -m
}

get_user() {
    whoami 2>/dev/null || echo "unknown"
}

get_uid() {
    id -u 2>/dev/null || echo "unknown"
}

is_root() {
    [[ $(get_uid) == "0" ]]
}

is_in_docker() {
    [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null
}

is_in_container() {
    is_in_docker || [[ -d /proc/1/root/.lxc ]]
}

is_in_vm() {
    [[ -d /proc/vz ]] || grep -q "qemu\|kvm\|virtualbox\|vmware" /proc/cpuinfo 2>/dev/null
}

json_init() {
    FINDINGS=()
    EXPLOITS=()
    CVES=()
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
    echo "{"
    echo "  \"timestamp\": \"$TIMESTAMP\","
    echo "  \"os\": \"$(get_os_info)\","
    echo "  \"kernel\": \"$(get_kernel)\","
    echo "  \"arch\": \"$(get_arch)\","
    echo "  \"user\": \"$(get_user)\","
    echo "  \"is_root\": $(is_root && echo "true" || echo "false"),"
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

export_vars() {
    export RED GREEN YELLOW BLUE CYAN MAGENTA NC
    export BOLD ITALIC UNDERLINE
    export SED_RED SED_GREEN SED_YELLOW SED_BLUE SED_CYAN
    export SED_MAGENTA SED_LIGHT_CYAN SED_LIGHT_RED SED_LIGHT_GREEN
    export OUTPUT_FORMAT STEALTH_MODE VERBOSE QUICK_MODE
    export TIMEOUT_VALUE TIMESTAMP
}
