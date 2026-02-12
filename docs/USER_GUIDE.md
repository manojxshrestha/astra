# PwnTheBox User Guide

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Framework Overview](#framework-overview)
4. [Quick Start](#quick-start)
5. [Phase-by-Phase Guide](#phase-by-phase-guide)
   - [Phase 1: Reconnaissance](#phase-1-reconnaissance)
   - [Phase 2: Enumeration](#phase-2-enumeration)
   - [Phase 3: Exploitation](#phase-3-exploitation)
   - [Phase 4: Foothold](#phase-4-foothold)
   - [Phase 5: Privilege Escalation](#phase-5-privilege-escalation)
   - [Phase 6: Internal Recon](#phase-6-internal-recon)
   - [Phase 7: Lateral Movement](#phase-7-lateral-movement)
   - [Phase 8: Persistence](#phase-8-persistence)
   - [Phase 9: Actions on Objectives](#phase-9-actions-on-objectives)
6. [Command Reference](#command-reference)
7. [Configuration](#configuration)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)
10. [Legal Disclaimer](#legal-disclaimer)

---

## Introduction

PwnTheBox is a professional penetration testing framework designed for authorized security assessments and red team operations. The framework implements a comprehensive 9-phase methodology for conducting thorough security assessments.

### Key Features

- **Modular Architecture**: Each phase is独立 (independent) and can be used standalone
- **Interactive Menus**: User-friendly interface with guided workflows
- **Tool Integration**: Seamlessly integrates with industry-standard security tools
- **Output Organization**: Structured output with timestamped results
- **Cross-Platform**: Supports Linux and Windows post-exploitation

### Target Audience

- Professional penetration testers
- Red team operators
- Security consultants
- IT security professionals
- Certified ethical hackers

---

## Installation

### Prerequisites

```bash
# Required tools
sudo apt-get update
sudo apt-get install -y \
    nmap \
    gobuster \
    nikto \
    sqlmap \
    metasploit-framework \
    python3 \
    python3-pip \
    curl \
    wget \
    git
```

### Framework Installation

```bash
# Clone the repository
git clone https://github.com/manojxshrestha/pwnthebox.git
cd pwnthebox

# Make scripts executable
chmod +x pwnthebox.sh install.sh update.sh
chmod +x **/*.sh 2>/dev/null

# Run installation script
./install.sh

# Verify installation
./pwnthebox.sh --deps
```

### Tool Verification

```bash
# Check all dependencies
./pwnthebox.sh --deps

# Output should show all tools as "installed"
```

---

## Framework Overview

### Architecture

```
PwnTheBox/
├── pwnthebox.sh          # Main launcher
├── install.sh            # Installation script
├── update.sh             # Update script
├── README.md             # Main documentation
├── FRAMEWORK.md         # Framework documentation
├── KNOWN_ISSUES.md      # Known issues and limitations
├── docs/                 # User guides and documentation
├── data/                 # Output directory
├── wordlists/            # Wordlists and dictionaries
├── venv/                 # Python virtual environment
├── config/               # Configuration files
├── Recon/               # Phase 1: Reconnaissance
├── Enum/                # Phase 2: Enumeration
├── Exploit/             # Phase 3: Exploitation
├── Foothold/            # Phase 4: Foothold
├── Privilege-Escalation/ # Phase 5: Privilege Escalation
├── Internal/            # Phase 6: Internal Recon
├── Lateral/             # Phase 7: Lateral Movement
├── Persistence/         # Phase 8: Persistence
└── Misc/               # Phase 9: Actions on Objectives
```

### Phase Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                        PWNTHEBOX                                │
│              Professional Penetration Testing                    │
└─────────────────────────────────────────────────────────────────┘
                                 │
         ┌───────────┬───────────┼───────────┬───────────┐
         ▼           ▼           ▼           ▼           ▼
    ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
    │  RECON  │ │   ENUM  │ │ EXPLOIT │ │ FOOTHOLD│ │ PRIVESC │
    │ Phase 1 │ │ Phase 2 │ │ Phase 3 │ │ Phase 4 │ │ Phase 5 │
    └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
         │           │           │           │           │
         └───────────┴───────────┼───────────┴───────────┘
                                   ▼
         ┌───────────┬───────────┼───────────┬───────────┐
         ▼           ▼           ▼           ▼           ▼
    ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
    │ INTERNAL│ │ LATERAL │ │PERSISTEN│ │ ACTIONS │ │  REPORT │
    │ Phase 6 │ │ Phase 7 │ │ Phase 8 │ │ Phase 9 │ │Summary  │
    └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
```

---

## Quick Start

### Launching the Framework

```bash
# Interactive menu
./pwnthebox.sh

# Direct phase access
./pwnthebox.sh 1      # Recon
./pwnthebox.sh 2      # Enumeration
./pwnthebox.sh 3      # Exploitation
./pwnthebox.sh 4      # Foothold
./pwnthebox.sh 5      # Privilege Escalation
./pwnthebox.sh 6      # Internal Recon
./pwnthebox.sh 7      # Lateral Movement
./pwnthebox.sh 8      # Persistence
./pwnthebox.sh 9      # Actions on Objectives

# Utility commands
./pwnthebox.sh --help     # Show help
./pwnthebox.sh --deps     # Check dependencies
./pwnthebox.sh --paths    # Show tool paths
./pwnthebox.sh --update   # Update framework
```

### Basic Workflow

```bash
# 1. Start the framework
./pwnthebox.sh

# 2. Select Phase 1 for reconnaissance
# 3. Gather target information
# 4. Move to Phase 2 for enumeration
# 5. Continue through phases as needed
```

---

## Phase-by-Phase Guide

### Phase 1: Reconnaissance

**Purpose**: Gather intelligence about the target

#### Menu Options

| Option | Description | Command |
|--------|-------------|---------|
| R1 | Domain Information | whois, dig, nslookup |
| R2 | DNS Enumeration | Passive DNS reconnaissance |
| R3 | Email Harvesting | theHarvester |
| R4 | Subdomain Discovery | Asset discovery |
| R5 | Google Dorks | Manual research |
| R6 | Social Media Recon | OSINT gathering |
| R7 | Network Discovery | Ping sweep |
| R8 | Traceroute | Network path analysis |
| R9 | Basic Port Scan | Quick nmap scan |
| R10 | OS Fingerprinting | OS detection |
| RA | Run All Scripts | Sequential automation |
| RB | Recon from List | Bulk target processing |

#### Usage Examples

```bash
# Domain reconnaissance
./Recon/recon-suite.sh R1 example.com

# Subdomain discovery
./Recon/recon-suite.sh R4 target.com

# Email harvesting
./Recon/recon-suite.sh R3 company.com

# Full reconnaissance
./Recon/recon-suite.sh RA target.com
```

#### Output Location

Results are saved to: `data/recon/`

---

### Phase 2: Enumeration

**Purpose**: Identify open ports, services, and vulnerabilities

#### Menu Options

| Option | Description | Command |
|--------|-------------|---------|
| E1 | Quick Port Scan | nmap -F |
| E2 | Full Port Scan | nmap -p- |
| E3 | Service Detection | nmap -sV |
| E4 | OS Fingerprinting | nmap -O |
| E5 | UDP Port Scan | nmap -sU |
| E6 | HTTP/HTTPS Enum | Web technology detection |
| E7 | SMB/Samba Enum | SMB enumeration |
| E8 | SNMP Enum | SNMP scanning |
| E9 | FTP Enum | FTP enumeration |
| E10 | SSH Enum | SSH enumeration |
| EV1 | Nikto Scanner | Web vulnerability scan |
| EV2 | SSL/TLS Analysis | SSL certificate analysis |
| EV3 | Directory Busting | Gobuster/dirsearch |
| EV4 | CVE Scanner | Vulnerability scanning |
| EV5 | Vulnerability Lists | Manual check guides |

#### Usage Examples

```bash
# Quick port scan
./Enum/enum-suite.sh E1 192.168.1.0/24

# Full port scan with service detection
./Enum/enum-suite.sh E2 10.10.10.0/24

# Nikto web scan
./Enum/enum-suite.sh EV1 http://example.com

# Directory busting
./Enum/enum-suite.sh EV3 http://example.com /usr/share/wordlists/dirb/common.txt
```

#### Output Location

Results are saved to: `data/enum/`

---

### Phase 3: Exploitation

**Purpose**: Exploit vulnerabilities to gain access

#### Menu Options

| Option | Description | Command |
|--------|-------------|---------|
| C1 | Payload Generator | msfvenom |
| C2 | Reverse Shell Gen | One-liner shells |
| C3 | Web Shell Gen | PHP/ASP/JSP shells |
| C4 | Encoding/Obfuscation | Payload encoding |
| CW1 | Web Exploitation | Web attack toolkit |
| CW2 | SQL Injection | sqlmap automation |
| CW3 | Command Injection | Command injection testing |
| CW4 | File Upload | Upload vulnerability testing |
| CW5 | LFI/RFI Testing | File inclusion testing |
| CN1 | Network Exploitation | Exploit scripts |
| CN2 | Metasploit | MSF console integration |
| CB1 | Binary Analysis | ELF analysis |
| CB2 | Fuzzer | Application fuzzing |

#### Usage Examples

```bash
# Generate reverse shell payload
./Exploit/compromise-suite.sh C1
# Enter LHOST: 192.168.1.100
# Enter LPORT: 443
# Enter payload: linux/x64/meterpreter_reverse_tcp

# SQL injection testing
./Exploit/compromise-suite.sh CW2
# Enter vulnerable URL: http://example.com/page?id=1

# Start Metasploit
./Exploit/compromise-suite.sh CN2
```

#### Output Location

Results are saved to: `data/exploit/`

---

### Phase 4: Foothold

**Purpose**: Stabilize and maintain access

#### Menu Options

| Option | Description | Command |
|--------|-------------|---------|
| F1 | Python PTY Spawn | Upgrade shell to PTY |
| F2 | Shell Upgrade | Interactive shell setup |
| F3 | Terminal Settings | TERM environment |
| F4 | Netcat Listener | Start nc listener |
| F5 | Metasploit Handler | Start MSF handler |
| F6 | Multi-handler | Generic reverse handler |
| F7 | Check Sessions | List active sessions |
| F8 | Session Management | Background/foreground |
| F9 | Upgrade to Meterpreter | Session upgrade |

#### Usage Examples

```bash
# Start netcat listener
./Foothold/foothold-suite.sh F4
# Enter port: 443

# Start Metasploit handler
./Foothold/foothold-suite.sh F5
# Enter LHOST: 192.168.1.100
# Enter LPORT: 443

# Upgrade shell
./Foothold/foothold-suite.sh F1
```

#### Output Location

Results are saved to: `data/foothold/`

---

### Phase 5: Privilege Escalation

**Purpose**: Gain higher privileges on compromised system

#### Sub-menu Options

| Option | Description |
|--------|-------------|
| PE1 | Linux PrivEsc Check |
| PE2 | Sudo Rights Abuse |
| PE3 | Kernel Exploits |
| PE4 | Path Hijacking |
| PE5 | Cron Job Abuse |
| PE6 | SetUID Exploits |
| PE7 | Docker Escape |
| PE8 | Windows PrivEsc |
| PE9 | AlwaysInstallElevated |
| PE10 | UAC Bypass |

#### Usage Examples

```bash
# Linux privilege escalation check
./Privilege-Escalation/Linux/privesc.sh

# Check sudo rights
sudo -l

# Search for SUID binaries
find / -perm -4000 2>/dev/null
```

#### Output Location

Results are saved to: `data/privesc/`

---

### Phase 6: Internal Recon

**Purpose**: Enumerate internal network after compromise

#### Menu Options

| Option | Description | Command |
|--------|-------------|---------|
| I1 | Current User | whoami, id |
| I2 | All Users | /etc/passwd |
| I3 | Groups | Group membership |
| I4 | Sudo Privileges | sudo -l |
| I5 | Network Interfaces | ip addr |
| I6 | ARP Table | ip neigh |
| I7 | Routing Table | ip route |
| I8 | DNS Info | /etc/resolv.conf |
| I9 | Active Connections | ss/netstat |
| I10 | Running Services | ps, systemctl |
| I11 | Installed Software | dpkg/rpm |
| I12 | Cron Jobs | Scheduled tasks |
| I13 | Mounted Filesystems | mount, /etc/fstab |
| ID1-ID4 | Domain Enumeration | Windows AD queries |

#### Usage Examples

```bash
# User enumeration
./Internal/internal-recon-suite.sh I1

# Network reconnaissance
./Internal/internal-recon-suite.sh I5

# Domain enumeration (Windows)
./Internal/internal-recon-suite.sh ID1
```

#### Output Location

Results are saved to: `data/internal/`

---

### Phase 7: Lateral Movement

**Purpose**: Move through the network

#### Menu Options

| Option | Description | Command |
|--------|-------------|---------|
| L1 | SSH Local Port Forward | ssh -L |
| L2 | SSH Remote Port Forward | ssh -R |
| L3 | SSH SOCKS Proxy | ssh -D |
| L4 | SSH Jump Host | ssh -J |
| LW1 | psexec | Impacket psexec.py |
| LW2 | WMI Execution | wmiexec.py |
| LW3 | Pass-the-Hash | pth-winexe |
| LW4 | RDP Hijacking | tscon |
| LT1 | Chisel Tunnel | Chisel proxy |
| LT2 | Ligolo Proxy | Ligolo-ng |
| LT3 | Port Forwarding | SSH/socat |
| LT4 | Reverse Tunnels | SSH reverse |

#### Usage Examples

```bash
# SSH local port forward
./Lateral/lateral-suite.sh L1
# Jump host: user@192.168.1.50
# Target: 10.10.10.5:3389
# Local port: 4444

# psexec authentication
./Lateral/lateral-suite.sh LW1
# Target: 10.10.10.5
# Domain/user: domain\admin
# Password: ********

# Chisel tunnel
./Lateral/lateral-suite.sh LT1
```

#### Output Location

Results are saved to: `data/lateral/`

---

### Phase 8: Persistence

**Purpose**: Maintain access across reboots

#### Menu Options

| Option | Description | Platform |
|--------|-------------|----------|
| P1 | SSH Backdoor Keys | Linux |
| P2 | Cron Job | Linux |
| P3 | Systemd Service | Linux |
| P4 | rc.local | Linux |
| P5 | .bashrc Backdoor | Linux |
| PW1 | Scheduled Task | Windows |
| PW2 | Registry Run Keys | Windows |
| PW3 | Service Installation | Windows |
| PW4 | Startup Folder | Windows |
| PW5 | WMI Event Subscription | Windows |
| PWS1 | PHP Web Shell | Web |
| PWS2 | ASP Web Shell | Web |

#### Usage Examples

```bash
# SSH key persistence
./Persistence/persistence-suite.sh P1

# Cron job persistence
./Persistence/persistence-suite.sh P2
# IP: 192.168.1.100
# Port: 443

# Windows scheduled task
./Persistence/persistence-suite.sh PW1
```

#### Output Location

Results are saved to: `data/persistence/`

---

### Phase 9: Actions on Objectives

**Purpose**: Complete the mission objectives

#### Menu Options

| Option | Description | Command |
|--------|-------------|---------|
| O1 | Linux Credential Harvest | File hunting |
| O2 | Windows Credential Harvest | Mimikatz |
| O3 | Browser Credential Dump | Browser data |
| O4 | Memory Credential Dump | Procdump |
| O5 | Hash Extraction | unshadow |
| OC1 | Hash Cracking | hashcat/john |
| OC2 | Password Analysis | Wordlist analysis |
| OC3 | Log Analysis | Log grepping |
| OS1 | Steganography Detection | steghide/binwalk |
| OS2 | Hidden Data Extraction | File carving |
| OE1 | HTTP Exfiltration | curl |
| OE2 | DNS Exfiltration | DNS tunneling |

#### Usage Examples

```bash
# Credential harvesting
./Misc/actions-suite.sh O1

# Hash cracking
./Misc/actions-suite.sh OC1
# Hash file: hashes.txt
# Wordlist: /usr/share/wordlists/rockyou.txt

# Steganography analysis
./Misc/actions-suite.sh OS1
# Image file: secret.jpg
```

#### Output Location

Results are saved to: `data/actions/`

---

## Command Reference

### Framework Commands

| Command | Description |
|---------|-------------|
| `./pwnthebox.sh` | Launch interactive menu |
| `./pwnthebox.sh 1-9` | Direct phase access |
| `./pwnthebox.sh --help` | Show help message |
| `./pwnthebox.sh --deps` | Check dependencies |
| `./pwnthebox.sh --paths` | Show tool paths |
| `./pwnthebox.sh --update` | Update framework |

### Suite Commands

| Suite | Command |
|-------|---------|
| Recon | `./Recon/recon-suite.sh [option] [target]` |
| Enum | `./Enum/enum-suite.sh [option] [target]` |
| Exploit | `./Exploit/compromise-suite.sh [option]` |
| Foothold | `./Foothold/foothold-suite.sh [option]` |
| Internal | `./Internal/internal-recon-suite.sh [option]` |
| Lateral | `./Lateral/lateral-suite.sh [option]` |
| Persistence | `./Persistence/persistence-suite.sh [option]` |
| Actions | `./Misc/actions-suite.sh [option]` |

### Common Nmap Commands

```bash
# Quick scan
nmap -F <target>

# Full port scan
nmap -p- <target>

# Service detection
nmap -sV <target>

# OS fingerprinting
nmap -O <target>

# UDP scan
nmap -sU <target>

# Script scan
nmap --script=<script-name> <target>
```

---

## Configuration

### Environment Variables

```bash
# Set output directory
export PWNTHEBOX_OUTPUT="/home/pwn/pwnthebox/data"

# Set default wordlist
export PWNTHEBOX_WORDLISTS="/usr/share/wordlists"

# Enable verbose output
export PWNTHEBOX_VERBOSE=1
```

### Wordlist Configuration

Default wordlists are expected at:
- `/usr/share/wordlists/SecLists/`
- `/usr/share/wordlists/dirb/`
- `/usr/share/metasploit-framework/data/wordlists/`

### Custom Configurations

Create a config file at: `config/pwnthebox.conf`

```bash
# config/pwnthebox.conf
OUTPUT_DIR="/home/pwn/pwnthebox/data"
WORDLISTS="/opt/wordlists"
NMAP_ARGS="-T4 -A"
GOBUSTER_THREADS=10
```

---

## Troubleshooting

### Common Issues

#### 1. Permission Denied

```bash
# Fix: Make scripts executable
chmod +x **/*.sh 2>/dev/null
chmod +x pwnthebox.sh
```

#### 2. Tool Not Found

```bash
# Check: Is tool installed?
which nmap
which gobuster

# Fix: Install missing tools
./install.sh
```

#### 3. Database Errors (Metasploit)

```bash
# Fix: Initialize Metasploit database
msfdb init
msfconsole -q -x "db_status; exit"
```

#### 4. Python Module Errors

```bash
# Fix: Install Python dependencies
pip3 install -r requirements.txt
source venv/bin/activate
pip install -r requirements.txt
```

### Getting Help

```bash
# Framework help
./pwnthebox.sh --help

# Check known issues
cat KNOWN_ISSUES.md

# View documentation
cat docs/USER_GUIDE.md
```

---

## Best Practices

### Engagement Preparation

1. **Scope Definition**
   - Define clear engagement scope
   - Document target IP ranges
   - Identify constraints and rules of engagement

2. **Pre-Engagement Briefing**
   - Confirm authorization
   - Establish communication channels
   - Set up reporting cadence

3. **Environment Setup**
   ```bash
   # Use dedicated testing environment
   ./install.sh
   ./pwnthebox.sh --deps
   
   # Verify all tools work
   ```

### During Assessment

1. **Documentation**
   - Log all commands executed
   - Save all output
   - Document timeline

2. **Output Management**
   ```bash
   # Use organized output directory
   data/
   ├── recon/
   ├── enum/
   ├── exploit/
   └── ...
   ```

3. **Privilege Handling**
   - Minimize privilege usage
   - Document privilege level
   - Use appropriate tools

### Post-Engagement

1. **Cleanup**
   - Remove created accounts
   - Delete backdoors
   - Clear logs if necessary

2. **Reporting**
   - Compile findings
   - Document evidence
   - Provide recommendations

---

## Legal Disclaimer

### IMPORTANT - READ BEFORE USE

**By using PwnTheBox, you agree to the following:**

1. **Authorization Required**
   - You MUST have explicit written authorization before testing any system
   - Unauthorized penetration testing is illegal
   - Violation of this requirement may result in criminal prosecution

2. **Scope Compliance**
   - Stay within the authorized scope
   - Do not test systems outside the defined scope
   - Report all findings according to engagement rules

3. **No Warranty**
   - PwnTheBox is provided "as is"
   - No warranty of any kind
   - Use at your own risk

4. **Liability**
   - The authors accept no liability
   - Users are responsible for their actions
   - Damage caused by misuse is the user's responsibility

### Appropriate Use Cases

- Authorized penetration tests
- Red team exercises
- Security assessments
- Bug bounty programs
- Capture the Flag (CTF) competitions
- Security training and education

### Prohibited Use Cases

- Unauthorized system access
- Malicious attacks
- Data theft
- Service disruption
- Any illegal activity

---

## Support

### Documentation
- README.md - Framework overview
- FRAMEWORK.md - Technical documentation
- docs/USER_GUIDE.md - This guide
- KNOWN_ISSUES.md - Known issues

### Reporting Issues
- GitHub Issues: https://github.com/manojxshrestha/pwnthebox/issues

### Contributing
- Fork the repository
- Create feature branch
- Submit pull request

---

## Version History

### v10 (Current)
- Complete suite script redesign
- Interactive command execution
- Enhanced output organization
- Comprehensive documentation
- Tool integration improvements

### v1.0
- Initial release
- Basic suite scripts
- Limited documentation

---

## Credits

developed by me

---

**Document Version**: v10  
**Last Updated**: 2024  
**Framework Version**: 2.0
