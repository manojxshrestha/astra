#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../utils/helpers.sh"

check_network_interfaces() {
    print_title "NETWORK INTERFACES"
    
    print_info "Network interfaces:"
    get_network_info
    
    echo ""
}

check_arp_table() {
    print_title "ARP TABLE"
    
    print_info "ARP neighbors:"
    ip neigh show 2>/dev/null || arp -a 2>/dev/null | head -20
    
    echo ""
}

check_listening_ports() {
    print_title "LISTENING PORTS"
    
    print_info "Listening services:"
    get_listening_ports | head -30
    
    print_subtitle "Listening processes:"
    ss -tulpn 2>/dev/null | grep LISTEN | awk '{print $5, $7}' | head -20
    
    echo ""
}

check_tcpdump() {
    print_title "TCPDUMP CAPABILITIES"
    
    if command -v tcpdump >/dev/null 2>&1; then
        print_info "tcpdump found"
        
        if is_suid "$(command -v tcpdump)" || is_sgid "$(command -v tcpdump)"; then
            print_high "tcpdump has SUID/SGID bit set"
            print_warn "Can capture network traffic"
            
            [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "network" "high" "tcpdump SUID" "Can capture network traffic" "N/A"
            
            print_subtitle "Exploitation:"
            print_command "# Capture credentials from network"
            print_command "tcpdump -i eth0 -w capture.pcap"
            print_command "# Later analyze for sensitive data"
            print_command "strings capture.pcap | grep -i password"
            
            if [[ -n "$STRACE_CMD" ]]; then
                print_command "# Or exploit via strace"
                print_command "timeout 2 tcpdump -i eth0 -c 1 2>&1 | strace -f -o /tmp/trace.txt"
            fi
        fi
    else
        print_info "tcpdump not found"
    fi
    
    echo ""
}

check_r_services() {
    print_title "R-SERVICES TRUST RELATIONSHIPS"
    
    print_info "Checking for r-services configuration..."
    
    local r_files=("/etc/hosts.equiv" "/etc/hosts.lpd" "~/.rhosts" "~/.netrc")
    
    for file in "${r_files[@]}"; do
        local expanded_file=$(eval echo "$file")
        if [[ -f "$expanded_file" ]]; then
            local perms=$(get_file_perms "$expanded_file")
            print_warn "$file found with permissions: $perms"
            
            if [[ -r "$expanded_file" ]]; then
                print_info "Contents:"
                cat "$expanded_file" 2>/dev/null | head -20
                
                [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "network" "high" "R-services trust file" "$file" "Can establish trusted relationships"
            fi
        fi
    done
    
    print_subtitle "R-services exploitation:"
    print_command "# If hosts.equiv contains '+' (trust all)"
    print_command "# Can login without authentication"
    print_command "rlogin -l root target"
    print_command "rsh -l root target"
    print_command ""
    print_command "# Copy files"
    print_command "rcp /tmp/exploit.sh root@target:/tmp/"
    
    echo ""
}

check_nfs_exports() {
    print_title "NFS EXPORTS"
    
    if [[ -f /etc/exports ]]; then
        print_info "NFS exports (/etc/exports):"
        cat /etc/exports 2>/dev/null
        
        print_subtitle "NFS exploitation:"
        print_command "# Showmount"
        print_command "showmount -e target"
        print_command ""
        print_command "# Mount NFS share"
        print_command "mount -t nfs target:/share /mnt/nfs"
        print_command ""
        print_command "# If no_root_squash is set"
        print_command "# Create SUID binary on mount"
        print_command "gcc /tmp/rootshell.c -o /mnt/nfs/rootshell"
        print_command "chmod u+s /mnt/nfs/rootshell"
        print_command "# Then execute on target"
        
        if grep -q "no_root_squash" /etc/exports 2>/dev/null; then
            print_high "no_root_squash found in NFS exports!"
            [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "nfs" "high" "NFS no_root_squash" "Can create SUID binaries on NFS share" "N/A"
        fi
    else
        print_info "No NFS exports found"
    fi
    
    echo ""
}

check_iptables_rules() {
    print_title "IPTABLES RULES"
    
    if command -v iptables >/dev/null 2>&1; then
        print_info "iptables rules:"
        iptables -L 2>/dev/null | head -30 || print_warn "Cannot read iptables"
    else
        print_info "iptables not found"
    fi
    
    echo ""
}

check_processes() {
    print_title "PROCESS ANALYSIS"
    
    print_info "Running processes:"
    get_process_list | head -30
    
    echo ""
}

check_processes_different_user() {
    print_title "PROCESSES RUNNING AS OTHER USERS"
    
    print_info "Processes running as root:"
    ps aux 2>/dev/null | grep "^root" | grep -v grep | head -20
    
    print_info ""
    
    print_info "Processes running as other users:"
    ps aux 2>/dev/null | grep -v "^root" | grep -v "^$(whoami)" | head -20
    
    print_subtitle "Exploitation:"
    print_command "# If you can attach to processes with ptrace"
    print_command "gdb -p <PID>"
    print_command "(gdb) call (void)system(\"/bin/sh\")"
    print_command ""
    print_command "# Or use ptrace"
    print_command "strace -p <PID>"
    
    if [[ -n "$STRACE_CMD" ]]; then
        print_warn "strace available - check if can attach to processes"
    fi
    
    echo ""
}

check_deleted_binaries() {
    print_title "DELETED BINARIES STILL RUNNING"
    
    print_info "Checking for deleted binaries still running..."
    
    if [[ -r /proc ]]; then
        for pid in $(ls /proc 2>/dev/null | grep -E '^[0-9]+$'); do
            if [[ -L "/proc/$pid/exe" ]]; then
                local exe_link=$(readlink "/proc/$pid/exe" 2>/dev/null)
                if [[ "$exe_link" == *"deleted"* ]]; then
                    local cmdline=$(cat "/proc/$pid/cmdline" 2>/dev/null | tr '\0' ' ')
                    print_warn "Deleted binary running: PID $pid - $cmdline"
                fi
            fi
        done
    fi
    
    echo ""
}

check_files_open_by_others() {
    print_title "FILES OPENED BY OTHER PROCESSES"
    
    print_info "Checking for files opened by other processes..."
    
    if command -v lsof >/dev/null 2>&1; then
        print_command "# List files opened by root processes"
        print_command "sudo lsof -p \$(pgrep -u root) 2>/dev/null | head -30"
    else
        print_info "lsof not available"
        print_command "# Alternative using /proc"
        print_command "ls -la /proc/*/fd 2>/dev/null | grep -v proc | head -20"
    fi
    
    echo ""
}

run_network_process_checks() {
    check_network_interfaces
    check_arp_table
    check_listening_ports
    check_tcpdump
    check_r_services
    check_nfs_exports
    check_iptables_rules
    check_processes
    check_processes_different_user
    check_deleted_binaries
    check_files_open_by_others
}
