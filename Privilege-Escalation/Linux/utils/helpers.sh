#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

COMMON_PWD_PATTERNS="password pwd passwd pass user username login db_password admin_password api_key secret token credential"
NOT_EXTENSIONS="\.(mp3|mp4|jpg|jpeg|png|gif|ico|ttf|woff|woff2|eot|otf|svg|webp)$"

check_tool() {
    local tool="$1"
    command -v "$tool" >/dev/null 2>&1
}

get_tool() {
    local tool="$1"
    local alt="$2"
    
    if check_tool "$tool"; then
        echo "$tool"
    elif [[ -n "$alt" ]] && check_tool "$alt"; then
        echo "$alt"
    else
        echo ""
    fi
}

TIMEOUT_CMD=$(get_tool "timeout" "")
STRINGS_CMD=$(get_tool "strings" "")
STRACE_CMD=$(get_tool "strace" "")
LDD_CMD=$(get_tool "ldd" "")
READELF_CMD=$(get_tool "readelf" "")
CURL_CMD=$(get_tool "curl" "wget")
JQ_CMD=$(get_tool "jq" "")
CAPSH_CMD=$(get_tool "capsh" "")
GETCAP_CMD=$(get_tool "getcap" "")

FIND_CMD="find"
GREP_CMD="grep"
SED_CMD="sed"
AWK_CMD="awk"

fast_find() {
    local path="$1"
    local maxdepth="${2:-3}"
    $FIND_CMD "$path" -maxdepth "$maxdepth" -type f 2>/dev/null
}

safe_grep() {
    local pattern="$1"
    local path="${2:-/}"
    local extra_opts="${3:-}"
    
    if [[ -n "$TIMEOUT_CMD" ]] && [[ "$QUICK_MODE" == "true" ]]; then
        timeout 5 $GREP_CMD -rnIi "$pattern" "$path" $extra_opts 2>/dev/null | head -20
    else
        $GREP_CMD -rnIi "$pattern" "$path" $extra_opts 2>/dev/null | head -50
    fi
}

check_file_readable() {
    local file="$1"
    [[ -r "$file" ]] 2>/dev/null
}

check_file_writable() {
    local file="$1"
    [[ -w "$file" ]] 2>/dev/null
}

check_file_executable() {
    local file="$1"
    [[ -x "$file" ]] 2>/dev/null
}

is_suid() {
    local file="$1"
    [[ -u "$file" ]] 2>/dev/null
}

is_sgid() {
    local file="$1"
    [[ -g "$file" ]] 2>/dev/null
}

get_file_perms() {
    local file="$1"
    ls -ld "$file" 2>/dev/null
}

decode_capabilities() {
    local value="$1"
    
    if [[ -n "$CAPSH_CMD" ]]; then
        $CAPSH_CMD --decode="0x$value" 2>/dev/null || echo "0x$value"
    else
        echo "0x$value"
    fi
}

check_curl() {
    [[ -n "$CURL_CMD" ]]
}

download_file() {
    local url="$1"
    local output="$2"
    
    if [[ -n "$CURL_CMD" ]]; then
        $CURL_CMD -sL "$url" -o "$output" 2>/dev/null
    elif [[ -n "$(get_tool wget)" ]]; then
        wget -q "$url" -O "$output" 2>/dev/null
    else
        return 1
    fi
}

check_internet() {
    if [[ -n "$CURL_CMD" ]]; then
        $CURL_CMD -s --connect-timeout 5 https://google.com >/dev/null 2>&1
    else
        return 1
    fi
}

get_process_list() {
    ps aux 2>/dev/null || ps -ef 2>/dev/null
}

get_listening_ports() {
    if [[ -n "$(get_tool ss)" ]]; then
        ss -tulpn 2>/dev/null
    elif [[ -n "$(get_tool netstat)" ]]; then
        netstat -tulpn 2>/dev/null
    fi
}

get_cron_jobs() {
    cat /etc/crontab 2>/dev/null
    ls -la /etc/cron.d/ 2>/dev/null
    ls -la /etc/cron.hourly/ 2>/dev/null
    ls -la /etc/cron.daily/ 2>/dev/null
    ls -la /etc/cron.weekly/ 2>/dev/null
    ls -la /etc/cron.monthly/ 2>/dev/null
}

get_sudoers() {
    cat /etc/sudoers 2>/dev/null
    ls -la /etc/sudoers.d/ 2>/dev/null
}

get_passwd_file() {
    cat /etc/passwd 2>/dev/null
}

get_group_file() {
    cat /etc/group 2>/dev/null
}

get_shadow_file() {
    cat /etc/shadow 2>/dev/null
}

search_passwords() {
    local paths="$1"
    local patterns="$COMMON_PWD_PATTERNS"
    
    for path in $paths; do
        if [[ -d "$path" ]] && [[ -r "$path" ]]; then
            timeout_command "$GREP_CMD -rnIiE '($patterns).*[=:].+' $path 2>/dev/null | head -10"
        fi
    done
}

search_ssh_keys() {
    find / -name "id_rsa" -o -name "id_dsa" -o -name "id_ecdsa" -o -name "id_ed25519" 2>/dev/null | head -20
}

search_config_files() {
    local paths="/etc /var/www /opt /usr/local/etc"
    
    for path in $paths; do
        if [[ -d "$path" ]]; then
            find "$path" -name "*.conf" -o -name "*.cnf" -o -name "*.config" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" 2>/dev/null | head -30
        fi
    done
}

get_mounted_info() {
    mount 2>/dev/null
    cat /etc/fstab 2>/dev/null
}

get_network_info() {
    ip addr 2>/dev/null || ifconfig -a 2>/dev/null
    ip route 2>/dev/null || route -n 2>/dev/null
    cat /etc/hosts 2>/dev/null
}

get_kernel_modules() {
    lsmod 2>/dev/null
    cat /proc/modules 2>/dev/null
}

get_dmesg() {
    dmesg 2>/dev/null | head -50
}

get_system_info() {
    uname -a
    cat /etc/os-release 2>/dev/null
    cat /etc/issue 2>/dev/null
}

get_user_history() {
    cat ~/.bash_history 2>/dev/null | tail -50
    cat ~/.zsh_history 2>/dev/null | tail -50
    cat ~/.mysql_history 2>/dev/null 2>/dev/null
    cat ~/.psql_history 2>/dev/null 2>/dev/null
}

check_cloud_metadata() {
    local ips=("169.254.169.254" "169.254.169.254" "metadata.google.internal")
    local results=""
    
    for ip in "${ips[@]}"; do
        if [[ -n "$CURL_CMD" ]]; then
            local response=$($CURL_CMD -s --connect-timeout 2 "$ip" 2>/dev/null)
            if [[ -n "$response" ]]; then
                results="$results\n$ip: available"
            fi
        fi
    done
    
    echo -e "$results"
}

check_docker_socket() {
    if [[ -S /var/run/docker.sock ]]; then
        echo "Docker socket found: /var/run/docker.sock"
        ls -la /var/run/docker.sock 2>/dev/null
    fi
}

check_writable_paths() {
    local paths="/tmp /var/tmp /dev/shm /home /root"
    
    for path in $paths; do
        if [[ -d "$path" ]] && [[ -w "$path" ]]; then
            echo "Writable: $path"
        fi
    done
}

get_env_vars() {
    env 2>/dev/null | grep -iE "(password|secret|key|token|credential)" | head -20
}

get_shell_history() {
    local history_dirs=("~" "/root" "/home/*")
    
    for dir in "${history_dirs[@]}"; do
        local expanded_dir=$(eval echo "$dir")
        if [[ -d "$expanded_dir" ]]; then
            cat "$expanded_dir/.bash_history" 2>/dev/null | tail -100
        fi
    done
}

check_mysql_access() {
    mysql -u root -e "SELECT user,host FROM mysql.user;" 2>/dev/null || echo "MySQL access not available"
}

check_pg_access() {
    psql -U postgres -c "SELECT usename, usesysid FROM pg_user;" 2>/dev/null || echo "PostgreSQL access not available"
}

export -f check_tool get_tool timeout_command fast_find safe_grep
export -f check_file_readable check_file_writable check_file_executable
export -f is_suid is_sgid get_file_perms
export -f decode_capabilities check_curl download_file check_internet
export -f get_process_list get_listening_ports get_cron_jobs
export -f get_sudoers get_passwd_file get_group_file get_shadow_file
export -f search_passwords search_ssh_keys search_config_files
export -f get_mounted_info get_network_info get_kernel_modules
export -f get_dmesg get_system_info get_user_history
export -f check_cloud_metadata check_docker_socket check_writable_paths
export -f get_env_vars get_shell_history check_mysql_access check_pg_access
