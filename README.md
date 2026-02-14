# 🛡️ pwnthebox Framework

<div align="center">

[![Version](https://img.shields.io/badge/version-1.0-blue.svg)](https://github.com/manojxshrestha/pwnthebox)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Kali%20Linux%20%7C%20WSL%20%7C%20Parrot%20OS-blue.svg)](https://github.com/manojxshrestha/pwnthebox)
[![Shell](https://img.shields.io/badge/shell-Bash%205.0+-yellow.svg)](https://www.gnu.org/software/bash/)
[![Python](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/)

**Professional Vulnerability Assessment & Penetration Testing Toolkit**

*A comprehensive 9-phase penetration testing framework for authorized security assessments*

[🚀 Quick Start](#-quick-start) • [📖 Documentation](docs/USER_GUIDE.md) • [🔧 Installation](#-installation) • [⚠️ Disclaimer](#-disclaimer)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [✨ Features](#-features)
- [🛠️ Installation](#️-installation)
- [🚀 Quick Start](#-quick-start)
- [📁 Structure](#-directory-structure)
- [🎯 Usage](#-usage)
- [🔧 Configuration](#-configuration)
- [📚 Documentation](#-documentation)
- [🤝 Contributing](#-contributing)
- [⚠️ Disclaimer](#-disclaimer)

---

## 📋 Overview

pwnthebox is a professional-grade penetration testing framework designed for comprehensive security assessments. Following industry-standard methodologies, it provides a structured approach to vulnerability assessment and exploitation through a modular 9-phase lifecycle.

### 🎯 Purpose

- **Authorized Penetration Testing**: Professional security assessments
- **Red Team Operations**: Simulated adversary attacks
- **Vulnerability Assessment**: Systematic flaw identification
- **Security Training**: Educational security exercises
- **CTF Competitions**: Capture the flag challenges

### 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         pwnthebox Framework                          │
│                  Professional Penetration Testing                      │
└─────────────────────────────────────────────────────────────────────┘
                                 │
     ┌──────────┬──────────┬─────┴────┬──────────┬──────────┐
     ▼          ▼          ▼          ▼          ▼          ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│  RECON │ │  ENUM  │ │EXPLOIT │ │FOOTHOLD│ │PRIVESC │ │INTERNAL│
│ Phase 1│ │ Phase 2│ │ Phase 3│ │ Phase 4│ │ Phase 5│ │ Phase 6│
└────────┘ └────────┘ └────────┘ └────────┘ └────────┘ └────────┘
     │          │          │          │          │          │
     └──────────┴──────────┴─────┬────┴──────────┴──────────┘
                                  ▼
     ┌──────────┬──────────┬─────┴────┬──────────┬──────────┐
     ▼          ▼          ▼          ▼          ▼          ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│LATERAL │ │PERSIST │ │ ACTIONS│ │REPORTS │ │  DATA  │ │ CONFIG │
│ Phase 7│ │ Phase 8│ │ Phase 9│ │Summary  │ │  Output│ │ Files  │
└────────┘ └────────┘ └────────┘ └────────┘ └────────┘ └────────┘
```

---

## ✨ Features

### 🔐 Smart Installation System

| Feature | Description |
|---------|-------------|
| **Auto-Detection** | Identifies installed tools and skips redundant installations |
| **Progress Tracking** | Visual progress indicators with detailed status |
| **Multi-OS Support** | Kali Linux, WSL, Parrot OS, Ubuntu, Debian, Arch, macOS |
| **Version Control** | Installs latest versions from official sources |
| **Python venv** | Isolated Python environment for dependency management |

### 🛠️ Comprehensive Tool Suite

#### Reconnaissance (Phase 1)
- DNSRecon, DNSTwist, Subfinder
- Recon-ng, SpiderFoot
- Maltego, theHarvester

#### Enumeration (Phase 2)
- Nmap with NSE scripts
- Gobuster, FFUF, Dirsearch
- SSL/TLS Analysis tools
- Nikto, OWASP ZAP

#### Exploitation (Phase 3)
- Metasploit Framework
- SQLMap, NoSQLMap
- Exploit-DB integration
- Binary exploitation (GDB, Pwndbg, ROPGadget)

#### Post-Exploitation (Phases 4-9)
- Shell stabilization tools
- Privilege escalation scripts
- Lateral movement tools (SSH, Chisel, Ligolo)
- Credential harvesting
- Persistence mechanisms
- Data exfiltration

#### Cryptography Tools
- Ciphey - Auto decoder (base, hex, classical ciphers)
- codext - Exotic encodings (base91, base65536)
- CTF-CryptoTool - Multi-cipher brute force
- RsaCtfTool - RSA attack toolkit
- Hash tools - Identification and cracking

#### Binary/Reversing Tools
- PwnPasi - Automated binary exploitation
- ROPgadget - Find ROP gadgets
- Checksec - Binary protection analysis
- pwndbg - GDB plugin for pwning
- Pwntools - Interactive debugger

### 🎨 User Interface

```
$ ./pwnthebox.sh

╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║                    🛡️ PWNTHEBOX FRAMEWORK                                ║
║              Professional Penetration Testing Toolkit                      ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

[1]    Reconnaissance       - Information gathering and OSINT
[2]    Enumeration           - Port scanning and service discovery
[3]    Exploitation          - Vulnerability exploitation
[4]    Foothold              - Shell stabilization
[5]    Privilege Escalation   - Root/admin access
[6]    Internal Recon        - Post-compromise enumeration
[7]    Lateral Movement      - Network pivoting
[8]    Persistence           - Maintain access
[9]    Actions on Objectives - Complete mission
[O]    OSINT                - Full OSINT automation
[C]    Crypto               - Cryptography tools
[B]    Binary/Reversing    - Binary exploitation

[0]    Exit

Enter choice: _
```

---

## 🛠️ Installation

### Prerequisites

```bash
# Required packages
sudo apt-get update
sudo apt-get install -y \
    git \
    bash \
    python3 \
    python3-pip \
    curl \
    wget \
    vim \
    tmux \
    netcat-traditional \
    nmap \
    golang-go
```

### Automated Installation

```bash
# Clone repository
git clone https://github.com/manojxshrestha/pwnthebox.git
cd pwnthebox

# Make executable
chmod +x pwnthebox.sh install.sh update.sh
chmod +x **/*.sh 2>/dev/null

# Install all tools (smart detection)
./install.sh

# Verify installation
./install.sh --check

# Launch framework
./pwnthebox.sh
```

### Installation Options

```bash
./install.sh              # Install all tools (skips already installed)
./install.sh --check     # Check installation status
./install.sh --help      # Show help message
./install.sh --force     # Force reinstall all tools
```

---

## 🚀 Quick Start

### Interactive Mode

```bash
# Launch interactive menu
./pwnthebox.sh

# Follow on-screen prompts
```

### Direct Phase Access

```bash
./pwnthebox.sh 1      # Reconnaissance
./pwnthebox.sh 2      # Enumeration
./pwnthebox.sh 3      # Exploitation
./pwnthebox.sh 4      # Foothold
./pwnthebox.sh 5      # Privilege Escalation
./pwnthebox.sh 6      # Internal Recon
./pwnthebox.sh 7      # Lateral Movement
./pwnthebox.sh 8      # Persistence
./pwnthebox.sh 9      # Actions on Objectives
```

### Utility Commands

```bash
./pwnthebox.sh --help     # Show help
./pwnthebox.sh --deps     # Check dependencies
./pwnthebox.sh --paths    # Show tool paths
./pwnthebox.sh --update   # Update framework
./pwnthebox.sh --version  # Show version
```

### Example Workflow

```bash
# 1. Start reconnaissance
./pwnthebox.sh 1
# Select R1 for domain information
# Enter target: example.com

# 2. Move to enumeration
./pwnthebox.sh 2
# Select E1 for port scan
# Enter target: 192.168.1.0/24

# 3. Continue through phases as needed
```

---

## 📁 Directory Structure

```
pwnthebox/
├── pwnthebox.sh              # 🎯 Main framework launcher
├── install.sh               # 🔧 Smart installation script
├── update.sh                # 🔄 Framework updater
├── README.md                # 📖 This file
├── FRAMEWORK.md            # 📚 Technical documentation
├── KNOWN_ISSUES.md         # ⚠️ Known issues and limitations
├── LICENSE                 # 📜 MIT License
│
├── 📂 docs/                      # 📖 Documentation
│   ├── USER_GUIDE.md           # Complete user guide
│   ├── API_SECURITY.md         # API testing guide
│   └── BINARY_EXPLOIT.md       # Binary exploitation guide
│
├── 📂 data/                      # 📊 Output directory
│   ├── recon/                  # Reconnaissance results
│   ├── enum/                   # Enumeration results
│   ├── exploit/               # Exploitation results
│   ├── foothold/              # Foothold results
│   ├── privesc/               # Privilege escalation results
│   ├── internal/              # Internal recon results
│   ├── lateral/               # Lateral movement results
│   ├── persistence/           # Persistence results
│   └── actions/               # Actions on objectives results
│
├── 📂 Recon/                   # Phase 1: Information Gathering
│   ├── recon-suite.sh         # Interactive recon menu
│   ├── domain.sh             # Domain reconnaissance
│   ├── passive.sh            # Passive reconnaissance
│   ├── person.sh             # Person/OSINT search
│   ├── generateTargets.sh    # Target generation
│   └── ping-sweep.sh         # Network discovery
│
├── 📂 Enum/                   # Phase 2: Scanning & Enumeration
│   ├── enum-suite.sh          # Interactive enum menu
│   ├── nse.sh                # Nmap Script Engine wrapper
│   ├── cve.sh                # CVE scanning
│   ├── web-tech.sh           # Web technology detection
│   └── nikto.sh              # Web vulnerability scanner
│
├── 📂 Exploit/                 # Phase 3: Initial Access
│   ├── compromise-suite.sh    # Interactive exploit menu
│   ├── payloads.sh           # Payload generation (msfvenom)
│   ├── shells.sh              # Reverse shell generator
│   ├── encoder.sh             # Encoding/obfuscation tools
│   ├── web-exploit.sh         # Web application exploitation
│   ├── ssl.sh                 # SSL/TLS analysis
│   ├── dev-api-scanner.sh     # API security scanner
│   ├── dev-web-api-scanner.sh # Web API scanner (MSF)
│   ├── elf/                   # ELF binary exploitation
│   │   └── elf.sh
│   └── fuzz/                  # Fuzzing tools
│       └── fuzzer.sh
│
├── 📂 Foothold/                # Phase 4: Shell Stabilization
│   ├── foothold-suite.sh      # Interactive foothold menu
│   └── listener.sh            # Reverse shell listeners
│
├── 📂 Privilege-Escalation/    # Phase 5: Privilege Escalation
│   ├── Linux/
│   │   ├── privesc.sh        # Linux PE checker
│   │   ├── checks/           # PE check modules
│   │   └── exploits/         # Exploit suggestions
│   └── Windows/
│       └── privesc.ps1       # Windows PE checker (PowerShell)
│
├── 📂 Internal/                 # Phase 6: Post-Compromise Recon
│   ├── internal-recon-suite.sh # Interactive internal menu
│   └── credentials/           # Credential harvesting
│
├── 📂 Lateral/                  # Phase 7: Lateral Movement
│   ├── lateral-suite.sh       # Interactive lateral menu
│   ├── ssh-pivot.sh           # SSH pivoting
│   ├── chisel-pivot.sh        # Chisel pivoting
│   └── socat-pivot.sh         # Socat pivoting
│
├── 📂 Persistence/             # Phase 8: Maintain Access
│   ├── persistence-suite.sh   # Interactive persistence menu
│   ├── Linux-persistence.sh   # Linux persistence
│   └── Windows-persistence.sh  # Windows persistence
│
├── 📂 Misc/                     # Phase 9: Actions on Objectives
│   ├── actions-suite.sh       # Interactive actions menu
│   ├── hashes/                # Hash cracking
│   │   ├── hashcat.sh
│   │   └── john.sh
│   ├── logs/                  # Log analysis
│   ├── stego/                 # Steganography
│   │   ├── stego.sh
│   │   └── extract.sh
│   ├── exfil/                 # Data exfiltration
│   └── report/                # Report generation
│       ├── report.sh
│       └── multiTabs.sh
│
├── 📂 config/                   # ⚙️ Configuration files
│   ├── tmux.conf              # Tmux configuration
│   ├── vimrc                  # Vim configuration
│   ├── zshrc                  # Zsh configuration
│   └── deploy/                # Deployment configurations
│
├── 📂 utils/                    # 🛠️ Utility scripts
│   ├── parse-nmap.py          # Nmap output parser
│   ├── parse-nessus.py        # Nessus output parser
│   ├── gen-random-string.py   # Random string generator
│   ├── exploit-db-search.py   # Exploit-DB search
│   └── cve-search.py          # CVE database search
│
├── 📂 wordlists/              # 📚 Wordlists and dictionaries
│   ├── custom.txt             # Custom wordlist
│   ├── bruteforce.txt         # Brute force wordlist
│   └── subdomains.txt        # Subdomain wordlist
│
└── 📂 venv/                    # 🐍 Python virtual environment
    ├── bin/
    ├── lib/
    ├── pyvenv.cfg
    └── requirements.txt
```

---

## 🎯 Usage

### Reconnaissance (Phase 1)

```bash
# Interactive menu
./Recon/recon-suite.sh

# Direct commands
./Recon/domain.sh example.com
./Recon/passive.sh target.com
./Recon/person.sh "John Doe"
./Recon/generateTargets.sh example.com
```

### Enumeration (Phase 2)

```bash
# Interactive menu
./Enum/enum-suite.sh

# Direct commands
./Enum/enum-suite.sh E1 192.168.1.0/24      # Quick port scan
./Enum/enum-suite.sh E2 10.10.10.0/24      # Full port scan
./Enum/enum-suite.sh EV1 http://example.com # Nikto scan
./Enum/nse.sh 192.168.1.100               # Nmap scripts
```

### Exploitation (Phase 3)

```bash
# Interactive menu
./Exploit/compromise-suite.sh

# Generate reverse shell payload
./Exploit/compromise-suite.sh C1
# LHOST: 192.168.1.100
# LPORT: 443
# Payload: linux/x64/meterpreter_reverse_tcp

# SQL Injection testing
./Exploit/compromise-suite.sh CW2
# Enter vulnerable URL: http://example.com/page?id=1

# API Security Scanner
./Exploit/dev-api-scanner.sh
```

### Privilege Escalation (Phase 5)

```bash
# Linux privilege escalation
./Privilege-Escalation/Linux/privesc.sh --all
./Privilege-Escalation/Linux/privesc.sh --kernel
./Privilege-Escalation/Linux/privesc.sh --suid

# Windows privilege escalation
pwsh -ep bypass -f Privilege-Escalation/Windows/privesc.ps1
```

### Lateral Movement (Phase 7)

```bash
# Interactive menu
./Lateral/lateral-suite.sh

# SSH local port forward
./Lateral/lateral-suite.sh L1
# Jump host: user@192.168.1.50
# Target: 10.10.10.5:3389
# Local port: 4444

# psexec
./Lateral/lateral-suite.sh LW1
# Target: 10.10.10.5
# Domain/user: domain\admin
# Password: ********
```

---

## 🔧 Configuration

### Environment Variables

```bash
# Set output directory
export PWNTHEBOX_OUTPUT="/home/pwn/pwnthebox/data"

# Set default wordlist path
export PWNTHEBOX_WORDLISTS="/usr/share/wordlists"

# Enable verbose output
export PWNTHEBOX_VERBOSE=1

# Set Nmap default arguments
export PWNTHEBOX_NMAP_ARGS="-T4 -A"
```

### Configuration File

Create `config/pwnthebox.conf`:

```bash
# pwnthebox Configuration

# Output directory
OUTPUT_DIR="/home/pwn/pwnthebox/data"

# Wordlists
WORDLISTS_DIR="/opt/wordlists"

# Nmap arguments
NMAP_ARGS="-T4 -A --script=vuln"

# Gobuster settings
GOBUSTER_THREADS=10
GOBUSTER_WORDLIST="/usr/share/wordlists/dirb/common.txt"

# Metasploit settings
MSF_DATA_DIR="/usr/share/metasploit-framework/data"
MSF_WORDLISTS="/usr/share/metasploit-framework/data/wordlists"

# Python venv
PYTHON_VENV="/home/pwn/pwnthebox/venv"

# Logging
LOG_LEVEL="INFO"
LOG_FILE="/home/pwn/pwnthebox/data/pwnthebox.log"
```

---

## 🔧 Binary/Reversing Suite

The Binary/Reversing Suite provides comprehensive tools for binary exploitation and reverse engineering tasks in CTF competitions and penetration testing.

### Menu Structure

```
─────── BINARY EXPLOITATION ───────

Automated Exploitation
   B1.  PwnPasi - Auto Binary Exploitation
   B2.  ROPgadget - Find ROP Gadgets

Binary Analysis
   B3.  Checksec - Binary Protections
   B4.  Extract Strings
   B5.  objdump - Disassemble Binary

Debugging
   B6.  pwndbg - GDB Plugin Info
   B7.  Pwntools - Interactive Debugger

Tools
   BA.  Install/Update All Tools
```

---

### B1. PwnPasi - Automated Binary Exploitation

| Aspect | Details |
|--------|---------|
| **What is it?** | Automated binary exploitation framework that finds and exploits vulnerabilities |
| **Why use it?** | Automates the exploit development process, saving time in CTFs |
| **What it does** | Detects buffer overflows, format strings, RCE, and generates exploits |
| **How to use** | Select B1, enter binary path, optionally add remote IP:port |
| **CTF Use** | Quickly exploit binary challenges without manual exploit coding |

**Usage:**
```
Select B1
Enter binary path: /path/to/binary
Enter target IP (press Enter for local): 10.10.10.10
Enter target port (press Enter for local): 1337
```

**Example:**
```bash
# Local binary exploitation
python3 ~/pwnpasi/pwnpasi.py -l ./vulnerable_binary

# Remote binary exploitation
python3 ~/pwnpasi/pwnpasi.py -l ./binary -ip 10.10.10.10 -p 1337
```

---

### B2. ROPgadget - Find ROP Gadgets

| Aspect | Details |
|--------|---------|
| **What is it?** | Tool for finding ROP (Return-Oriented Programming) gadgets in binaries |
| **Why use it?** | ROP is used to bypass DEP/ASLR by chaining existing code snippets |
| **What it does** | Finds useful gadgets (instructions + ret) for building ROP chains |
| **How to use** | Select B2, enter binary path, view available gadgets |
| **CTF Use** | Build ROP chains to achieve code execution in buffer overflows |

**Usage:**
```
Select B2
Enter binary path: /path/to/binary
```

**Common Commands:**
```bash
# Find all ROP gadgets
ROPgadget.py --binary ./binary

# Find specific gadgets (e.g., pop rdi; ret)
ROPgadget.py --binary ./binary | grep "pop rdi"

# Find syscall gadgets
ROPgadget.py --binary ./binary | grep "syscall"

# Generate ROP chain
ROPgadget.py --binary ./binary --ropchain
```

**Useful Gadgets:**
| Gadget | Use |
|--------|-----|
| `pop rdi; ret` | Control first argument (64-bit) |
| `pop rsi; ret` | Control second argument |
| `pop rdx; ret` | Control third argument |
| `syscall` | Invoke system calls |
| `ret` | Stack alignment |

---

### B3. Checksec - Binary Protection Analysis

| Aspect | Details |
|--------|---------|
| **What is it?** | Analyzes binary security protections |
| **Why use it?** | You need to know what protections to bypass before exploiting |
| **Protections checked** | NX, PIE, RELRO, Stack Canaries, FORTIFY |
| **How to use** | Select B3, enter binary path |
| **CTF Use** | Determine exploitation strategy based on security flags |

**Protection Flags:**
| Protection | Description | Bypass |
|------------|-------------|--------|
| **NX** | Non-executable stack | ROP, JOP |
| **PIE** | Position Independent Executable | Brute force, leak |
| **RELRO** | Relocation Read-Only | Partial vs Full |
| **Stack Canary** | Stack protector | Format string, overflow |
| **FORTIFY** | Buffer overflow protection | Careful crafting |

**Example Output:**
```
[*] '/path/to/binary'
    Arch:     amd64-64bit
    RELRO:    Full RELRO
    Stack:    Canary found
    NX:       NX enabled
    PIE:      PIE enabled
```

---

### B4. Extract Strings

| Aspect | Details |
|--------|---------|
| **What is it?** | Extracts readable strings from binary |
| **Why use it?** | Reveals hardcoded passwords, URLs, flags, function names |
| **How to use** | Select B4, enter binary, specify min length |
| **CTF Use** | Find flags, API keys, or hints in binary |

**Usage:**
```
Select B4
Enter binary path: /path/to/binary
Minimum string length (default 4): 6
```

**Commands:**
```bash
# Basic string extraction
strings -n 6 binary | head -50

# Unicode strings
strings -e l binary

# Strings with addresses
strings -t x binary

# Grep for interesting strings
strings binary | grep -i "password"
strings binary | grep -i "http"
strings binary | grep -i "flag"
```

---

### B5. objdump - Disassemble Binary

| Aspect | Details |
|--------|---------|
| **What is it?** | Disassembles binary to view assembly code |
| **Why use it?** | Understand binary logic, find vulnerabilities |
| **How to use** | Select B5, enter binary, enter function name |
| **CTF Use** | Analyze functions, find vulnerable code |

**Usage:**
```
Select B5
Enter binary path: /path/to/binary
Enter function name (or press Enter for main): main
```

**Commands:**
```bash
# Disassemble main function
objdump -d binary | grep -A 50 "<main>:"

# Disassemble specific function
objdump -d binary | grep -A 30 "<function_name>:"

# View all functions
objdump -d binary | grep -E "^[0-9a-f]+ <.*>:"

# View ELF headers
objdump -x binary

# View dynamic symbols
objdump -T binary
```

**Common x86_64 Instructions:**
| Instruction | Description |
|-------------|-------------|
| `mov` | Move data |
| `pop` | Pop from stack |
| `push` | Push to stack |
| `call` | Call function |
| `ret` | Return from function |
| `syscall` | System call |
| `cmp` | Compare values |
| `jmp` | Unconditional jump |
| `je/jne` | Conditional jumps |

---

### B6. pwndbg - GDB Plugin

| Aspect | Details |
|--------|---------|
| **What is it?** | GDB plugin specifically for pwning (binary exploitation) |
| **Why use it?** | Makes debugging binaries much easier with enhanced features |
| **Features** | Heap analysis, memory visualization, exploit development |
| **How to use** | Select B6, or run `gdb binary` with pwndbg loaded |
| **CTF Use** | Debug exploits, analyze binary behavior |

**Installation:**
```bash
# Via binary-suite (BA option)
cd ~/pwndbg && ./setup.sh
```

**Basic Commands:**
```bash
# Start debugging
gdb ./binary

# In pwndbg:
run                    # Run the program
break main            # Set breakpoint at main
continue              # Continue execution
next                  # Next instruction
step                  # Step into function
x/20gx $rsp          # Examine stack (20 qwords)
x/20i $pc            # Examine code
heap                  # Show heap info
bins                  # Show heap bins
find                  # Search memory
search                # Search for bytes in memory
```

**pwndbg Commands:**
| Command | Description |
|---------|-------------|
| `pwndbg> p x` | Pretty print variable x |
| `pwndbg> telescope` | Visual memory dump |
| `pwndbg> heap` | Heap analysis |
| `pwndbg> bins` | Fastbin/dunsbin/tcache |
| `pwndbg> rop` | ROP chain search |
| `pwndbg> regs` | Show registers |
| `pwndbg> stack` | Show stack |

---

### B7. Pwntools - Interactive Debugger

| Aspect | Details |
|--------|---------|
| **What is it?** | Python library for binary exploitation |
| **Why use it?** | Write exploits, interact with processes, create payloads |
| **Features** | Process interaction, shellcode generation, ELF parsing |
| **How to use** | Select B7, enter binary, use pwntools in venv |
| **CTF Use** | Build complex exploits and interact with remote services |

**Installation (in venv):**
```bash
source ~/pwnthebox/venv/bin/activate
pip install pwntools
```

**Example Exploit:**
```python
from pwn import *

# Local exploitation
p = process('./binary')
p.sendline(b'A' * 64 + p64(0xdeadbeef))
print(p.recv())

# Remote exploitation
p = remote('10.10.10.10', 1337)
p.sendline(b'payload')
print(p.recv())

# GDB attach
gdb.attach(binary, gdbscript='break main\ncontinue')
```

**Common pwntools Functions:**
| Function | Description |
|----------|-------------|
| `process()` | Start local process |
| `remote()` | Connect to remote |
| `send()` | Send data |
| `sendline()` | Send line with newline |
| `recv()` | Receive data |
| `interactive()` | Interactive mode |
| `packed()` | Create ROP chain |
| `elf()` | Parse ELF binary |

---

### BA. Install/Update Tools

| Aspect | Details |
|--------|---------|
| **What it does** | Installs all binary exploitation tools |
| **Tools installed** | pwnpasi, ROPgadget, pwndbg |
| **How to use** | Select BA from menu |

**Installation:**
```bash
# Clones and installs:
# - ~/pwnpasi - Automated exploitation
# - ~/ROPgadget - ROP gadget finder  
# - ~/pwndbg - GDB plugin
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [README.md](README.md) | This file - framework overview |
| [docs/USER_GUIDE.md](docs/USER_GUIDE.md) | Complete user guide |
| [FRAMEWORK.md](FRAMEWORK.md) | Technical documentation |
| [KNOWN_ISSUES.md](KNOWN_ISSUES.md) | Known issues and limitations |

### Documentation Sections

1. **Introduction** - Framework overview and purpose
2. **Installation** - Step-by-step setup guide
3. **Framework Overview** - Architecture and components
4. **Quick Start** - Getting started guide
5. **Phase-by-Phase Guide** - Detailed walkthrough of each phase
6. **Command Reference** - Complete command list
7. **Configuration** - Customization options
8. **Troubleshooting** - Common issues and solutions
9. **Best Practices** - Security assessment guidelines
10. **Legal Disclaimer** - Authorization requirements

---

## 🤝 Contributing

### Ways to Contribute

1. **Bug Reports**: Report issues via GitHub Issues
2. **Feature Requests**: Suggest new functionality
3. **Code Contributions**: Submit pull requests
4. **Documentation**: Improve guides and docs
5. **Tool Integration**: Add new security tools

### Development Setup

```bash
# Fork repository
git fork https://github.com/manojxshrestha/pwnthebox.git

# Clone your fork
git clone https://github.com/YOUR-USERNAME/pwnthebox.git
cd pwnthebox

# Create feature branch
git checkout -b feature/new-tool

# Make changes
# ...

# Commit changes
git add .
git commit -m "Add new tool integration"

# Push to your fork
git push origin feature/new-tool

# Create Pull Request
```

### Coding Standards

- Follow Bash best practices
- Use consistent formatting
- Add comments for complex logic
- Test scripts before submitting
- Update documentation as needed

---

## 📈 Roadmap

### Version 1.1.0 (Planned)
- [ ] REST API for remote control
- [ ] Web-based management interface
- [ ] Automated reporting system
- [ ] Multi-target assessment support
- [ ] Session management and persistence

### Version 1.2.0 (Planned)
- [ ] Cloud-specific modules (AWS, Azure, GCP)
- [ ] Container security assessments
- [ ] CI/CD integration
- [ ] Slack/Teams notifications
- [ ] Evidence collection automation

---

## 👥 Community

### Support

- **GitHub Issues**: [Report bugs](https://github.com/manojxshrestha/pwnthebox/issues)
- **Discussions**: [Community forum](https://github.com/manojxshrestha/pwnthebox/discussions)
- **Wiki**: [Project wiki](https://github.com/manojxshrestha/pwnthebox/wiki)

### Social

- **GitHub**: [@manojxshrestha](https://github.com/manojxshrestha)
- **X (Twitter)**: [@manojxshrestha](https://x.com/manojxshrestha)
- **LinkedIn**: [manojxshrestha](https://linkedin.com/in/manojxshrestha)

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Disclaimer

### 🚨 IMPORTANT - READ BEFORE USE

**By using pwnthebox, you agree to the following:**

### 1. Authorization Requirement

```
⚠️  YOU MUST HAVE EXPLICIT WRITTEN AUTHORIZATION  ⚠️

- Unauthorized penetration testing is ILLEGAL
- Violation may result in CRIMINAL PROSECUTION
- Always obtain proper authorization before testing
```

### 2. Scope Compliance

- Stay within the authorized scope
- Do not test systems outside defined scope
- Report all findings according to engagement rules
- Document all activities for audit trails

### 3. No Warranty

```
THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND
THE AUTHORS ACCEPT NO LIABILITY FOR ANY DAMAGE CAUSED
USE AT YOUR OWN RISK
```

### 4. Appropriate Use Cases

✅ **Authorized penetration tests**  
✅ **Red team exercises**  
✅ **Bug bounty programs**  
✅ **Security assessments**  
✅ **CTF competitions**  
✅ **Security training and education**  

### 5. Prohibited Use Cases

❌ **Unauthorized system access**  
❌ **Malicious attacks**  
❌ **Data theft**  
❌ **Service disruption**  
❌ **Any illegal activity**  

---

## 🙏 Acknowledgments

### Open Source Projects

- **Metasploit Framework** - Rapid7
- **Nmap** - Gordon Lyon
- **theHarvester** - Christian Martorella
- **SQLMap** - Bernardo Damele
- **Gobuster** - OJ Reeves
- **Impacket** - SecureAuth Corporation
- **And many more...**

### Security Communities

- Offensive Security
- Penetration Testing Framework community
- Bug bounty researchers
- Security training organizations

---

<div align="center">

**pwnthebox** - *Professional Penetration Testing Framework*

[![GitHub stars](https://img.shields.io/github/stars/manojxshrestha/pwnthebox?style=flat-square)](https://github.com/manojxshrestha/pwnthebox/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/manojxshrestha/pwnthebox?style=flat-square)](https://github.com/manojxshrestha/pwnthebox/network)
[![GitHub issues](https://img.shields.io/github/issues/manojxshrestha/pwnthebox?style=flat-square)](https://github.com/manojxshrestha/pwnthebox/issues)

</div>
