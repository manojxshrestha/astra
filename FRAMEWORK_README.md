# PwnTheBox Penetration Testing Framework

## Overview

PwnTheBox is a comprehensive penetration testing framework with a creative, clean directory structure. The framework is organized into 9 core phases plus miscellaneous utilities, making it easy to navigate and use.

## Directory Structure

```
PwnTheBox/
├── FRAMEWORK_README.md              # This file
├── pwnthebox.sh                     # Main menu launcher
│
├── Recon/                           # Phase 1: Information Gathering
│   ├── recon-suite.sh               # Recon menu wrapper
│   ├── domain.sh                    # Domain information
│   ├── passive.sh                   # Passive reconnaissance
│   ├── person.sh                    # Email/people harvesting
│   ├── generateTargets.sh            # Target generation
│   ├── ping-sweep.sh                # Network discovery
│   ├── *.sh                         # Other recon tools
│   └── README.md
│
├── Enum/                            # Phase 2: Scanning & Enumeration
│   ├── enum-suite.sh                # Enum menu wrapper
│   ├── nse.sh                       # Nmap script engine
│   ├── cve.sh                       # CVE scanning
│   ├── msf-aux.sh                   # Metasploit aux modules
│   └── README.md
│
├── Exploit/                         # Phase 3: Exploitation
│   ├── compromise-suite.sh          # Exploit menu wrapper
│   ├── payloads.sh                  # Payload generation
│   ├── shells.sh                    # Reverse shells
│   ├── encoder.sh                   # Encoding/obfuscation
│   ├── nikto.sh                     # Web vulnerability scanner
│   ├── ssl.sh                       # SSL/TLS analysis
│   ├── web-exploit.sh               # Web exploitation toolkit
│   ├── autopwn.sh                   # Automated exploitation
│   ├── elf/                         # ELF binary exploitation
│   │   └── elf.sh
│   ├── fuzz/                        # Fuzzing tools
│   │   └── fuzzer.sh
│   ├── encoders/                    # Various encoders
│   ├── exploitdb/                   # Exploit-DB scripts
│   ├── payloads/                    # Payload templates
│   ├── shells/                      # Shell scripts
│   └── README.md
│
├── Foothold/                        # Phase 4: Shell Stabilization
│   ├── foothold-suite.sh            # Foothold menu wrapper
│   └── listener.sh                 # Reverse listeners
│   └── README.md
│
├── Privilege-Escalation/           # Phase 5: Privilege Escalation
│   ├── Linux/
│   │   ├── privesc.sh               # Linux PE checker (v2.0)
│   │   ├── utils/                   # Utility functions
│   │   │   ├── colors.sh           # Color output
│   │   │   └── helpers.sh          # Helpers
│   │   ├── checks/                  # Enumeration checks
│   │   │   ├── system_info.sh      # System info
│   │   │   ├── suid_sgid.sh        # SUID/SGID binaries
│   │   │   ├── capabilities.sh     # Capabilities
│   │   │   ├── cron_jobs.sh        # Cron jobs
│   │   │   ├── passwords.sh        # Password hunting
│   │   │   ├── cloud_container.sh  # Cloud/container escapes
│   │   │   └── network_process.sh  # Network processes
│   │   └── exploits/                # Exploit suggestions
│   │       └── exploit_suggestions.sh
│   └── Windows/
│       └── privesc.ps1              # Windows PE checker
│
├── Persistence/                     # Phase 8: Maintaining Access
│   ├── persistence-suite.sh        # Persistence menu
│   └── README.md
│
├── Internal/                        # Phase 6: Post-Compromise Recon
│   ├── internal-recon-suite.sh     # Internal recon menu
│   ├── credentials/
│   │   └── creds.sh                 # Credential harvesting
│   └── README.md
│
├── Lateral/                         # Phase 7: Pivoting & Lateral Movement
│   ├── lateral-suite.sh             # Lateral menu wrapper
│   └── README.md
│
├── Misc/                            # Phase 9: Actions on Objectives
│   ├── actions-suite.sh             # Actions menu
│   ├── hashes/                      # Hash extraction/cracking
│   │   └── hashes.sh
│   ├── logs/                        # Log analysis
│   │   └── logs.sh
│   ├── stego/                       # Steganography
│   │   └── stego.sh
│   └── README.md
│
├── config/                          # Configuration files
│   ├── install.sh
│   ├── zshrc
│   ├── vimrc
│   ├── tmux.conf
│   └── deploy/                      # Deployment configs
│       ├── terraform/
│       └── ansible/
│
├── utils/                           # Utility scripts
│   ├── parse.sh                     # Output parsing
│   ├── parse-nmap.py                 # Nmap parser
│   ├── parse-nessus.py              # Nessus parser
│   ├── parse-burp.py                # Burp parser
│   └── *.py                         # Other utilities
│
├── post/                            # Post-exploitation utilities
│   └── update.sh
│
├── resource/                        # Metasploit resource files
│   ├── *.rc                         # Various RC files
│   └── msf-auto.sh
│
├── wordlists/                       # Wordlists and dictionaries
│
├── report/                          # Reporting tools
│   ├── report.sh
│   └── multiTabs.sh
│
└── reports/                         # Generated reports
```

## Quick Start

```bash
# Launch main menu
./pwnthebox.sh

# Run a specific phase
./Recon/recon-suite.sh --menu
./Enum/enum-suite.sh --menu
./Exploit/compromise-suite.sh --menu
./Foothold/foothold-suite.sh --menu
./Privilege-Escalation/Linux/privesc.sh --quick   # Linux PE
./Privilege-Escalation/Windows/privesc.ps1 -Quick # Windows PE
./Internal/internal-recon-suite.sh --menu
./Lateral/lateral-suite.sh --menu
./Persistence/persistence-suite.sh --menu
./Misc/actions-suite.sh --menu
```

## Phase Usage

### Recon - Information Gathering
```bash
./Recon/recon-suite.sh --menu
# R1 - Domain info, R2 - DNS enum, R3 - Email harvest
# R4 - Subdomains, R7 - Ping sweep, R8 - Traceroute
```

### Enum - Scanning & Enumeration
```bash
./Enum/enum-suite.sh --menu
# E1-E5 - Port scanning (quick, full, version, OS, UDP)
# EV1 - Nikto, EV2 - SSL/TLS, EV3 - Directory busting
```

### Exploit - Initial Access
```bash
./Exploit/compromise-suite.sh --menu
# C1 - Payloads, C2 - Reverse shells, C4 - Encoding
# CW1 - Web exploitation, CB1 - ELF binary, CB2 - Fuzzer
```

### Foothold - Shell Stabilization
```bash
./Foothold/foothold-suite.sh --menu
# F1-F9 - Listener setup, shell stabilization
```

### PE - Privilege Escalation
```bash
# Linux
./Privilege-Escalation/Linux/privesc.sh --quick          # Quick scan
./Privilege-Escalation/Linux/privesc.sh --json           # JSON output
./Privilege-Escalation/Linux/privesc.sh --stealth        # Stealth mode

# Windows
powershell -ep bypass -f Privilege-Escalation/Windows/privesc.ps1 -Quick
```

### Internal - Post-Compromise Recon
```bash
./Internal/internal-recon-suite.sh --menu
# I1-I13 - Internal network discovery, AD enum
```

### Lateral - Pivoting
```bash
./Lateral/lateral-suite.sh --menu
# L1-L4 - psexec, WMI, SMB, RDP
# LW1-LW4 - WinRM, Pass-the-Hash, Golden Ticket
```

### Persistence - Maintain Access
```bash
./Persistence/persistence-suite.sh --menu
# P1-P5 - Cron, SSH keys, Services, Web shells
# PW1-PW5 - Registry, Winlogon, Browser extensions
```

### Misc - Actions on Objectives
```bash
./Misc/actions-suite.sh --menu
# O1-O5 - Data exfiltration, Hashes, Logs, Stego
```

## Key Features

### Privilege Escalation Tools v2.0

**Linux privesc.sh:**
- Modular with 10+ check modules
- Color-coded severity (Critical/High/Medium/Low)
- JSON output (`--json`)
- Stealth mode (`--stealth`)
- Cloud metadata detection (AWS/Azure/GCP)
- Container escape (Docker/Kubernetes)
- GTFOBins integration
- Metasploit suggestions

**Windows privesc.ps1:**
- AlwaysInstallElevated
- Unquoted service paths
- Stored credentials
- DLL hijacking
- Print Spooler (PrintNightmare)
- Browser credentials
- WMI subscriptions
- GPP passwords

### Suite Wrapper Scripts

Each phase has a `*-suite.sh` wrapper with:
- Interactive menu interface
- Direct script execution
- Help documentation
- Colored output

## Best Practices

1. **Legal Authorization**: Always have written permission
2. **OPSEC**: Use `--stealth` mode when needed
3. **Documentation**: Use `--json` for automated reports
4. **Scope**: Stay within agreed boundaries
5. **Reporting**: Document findings with timestamps

## Requirements

- Linux/macOS (Bash scripts)
- Kali Linux or similar
- Common tools: nmap, msfvenom, nikto, burp-suite
- PowerShell 5.0+ for Windows scripts

## License

For educational and authorized testing purposes only. Use responsibly.

## Contributing

When adding scripts:
1. Place in appropriate phase directory
2. Create suite wrapper if adding multiple scripts
3. Update pwnthebox.sh if needed
4. Add documentation comments
5. Test before committing
