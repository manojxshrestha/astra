# PwnTheBox Penetration Testing Framework

## Overview

PwnTheBox is a comprehensive penetration testing framework organized according to the standard industry penetration testing lifecycle. The framework is structured into 9 phases, each containing specialized tools and scripts for that specific stage of a penetration test.

## Framework Lifecycle

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    PWNTHEBOX PENETRATION LIFECYCLE                      │
└─────────────────────────────────────────────────────────────────────────┘

  ┌──────────┐     ┌──────────────┐     ┌──────────────────┐
  │    01    │ --> │      02      │ --> │        03        │
  │ RECONNAIS│     │ ENUMERATION │     │ INITIAL COMPROMISE│
  │  SANCE   │     │ & VULNERAB. │     │                  │
  └──────────┘     └──────────────┘     └──────────────────┘
       │                  │                      │
       v                  v                      v
  Information        Open Ports,            Gain Initial
  Gathering           Services,               Access
                     Vulnerabilities

  ┌──────────┐     ┌──────────┐     ┌──────────────────┐
  │    04    │ --> │    05    │ --> │        06        │
  │ ESTABLISH │     │ PRIVILEGE│     │   INTERNAL RECON │
  │  FOOTHOLD │     │ ESCALAT. │     │                  │
  └──────────┘     └──────────┘     └──────────────────┘
       │                │                    │
       v                v                    v
  Stabilize,        Obtain               Post-Exploitation
  Listeners         Higher               Enumeration
                    Privileges

  ┌──────────┐     ┌──────────┐     ┌──────────────────┐
  │    07    │ --> │    08    │ --> │        09        │
  │  LATERAL │     │PERSISTENC│     │ACTIONS OBJECTIVES│
  │  MOVEMENT│     │    E     │     │                  │
  └──────────┘     └──────────┘     └──────────────────┘
       │                │                    │
       v                v                    v
  Pivot Through    Maintain               Complete
  Network          Access                  Mission
```

## Directory Structure

```
PwnTheBox/
├── FRAMEWORK_README.md              # This file
├── conductor.sh                     # Main menu launcher
├── 01-reconnaissance/               # Phase 1: Information gathering
│   ├── recon-suite.sh               # Suite wrapper with menu
│   ├── domain.sh                    # Domain information
│   ├── passive.sh                   # Passive reconnaissance
│   ├── person.sh                    # People/email harvesting
│   ├── generateTargets.sh           # Target generation
│   └── *.sh                         # Various recon tools
│
├── 02-enumeration-vulnerability/    # Phase 2: Scanning & enumeration
│   ├── enum-suite.sh                # Suite wrapper with menu
│   ├── nse.sh                       # Nmap script engine
│   ├── cve.sh                       # CVE vulnerability scanning
│   └── msf-aux.sh                   # Metasploit auxiliary modules
│
├── 03-initial-compromise/            # Phase 3: Exploitation
│   ├── compromise-suite.sh          # Suite wrapper with menu
│   ├── payloads.sh                  # Payload generation
│   ├── shells.sh                    # Reverse shells
│   ├── encoder.sh                   # Encoding/obfuscation
│   ├── nikto.sh                     # Web vulnerability scanner
│   ├── ssl.sh                       # SSL/TLS analysis
│   ├── web-exploit.sh               # Web exploitation toolkit
│   ├── autopwn.sh                   # Automated exploitation
│   ├── elf/                         # ELF binary exploitation
│   ├── fuzz/                        # Fuzzing tools
│   ├── encoders/                    # Various encoders
│   ├── exploitdb/                    # Exploit-DB scripts
│   ├── payloads/                    # Payload templates
│   └── shells/                      # Shell scripts
│
├── 04-establish-foothold/           # Phase 4: Shell stabilization
│   └── foothold-suite.sh            # Suite wrapper with menu
│       └── listener.sh              # Reverse listeners
│
├── 05-privilege-escalation/         # Phase 5: Local privilege escalation
│   ├── linux/
│   │   ├── privesc.sh               # Linux PE checker (v2.0)
│   │   ├── utils/                   # Utility functions
│   │   │   ├── colors.sh            # Color output helpers
│   │   │   └── helpers.sh           # Helper functions
│   │   ├── checks/                  # Enumeration checks
│   │   │   ├── system_info.sh      # System information
│   │   │   ├── suid_sgid.sh         # SUID/SGID binaries
│   │   │   ├── capabilities.sh      # Linux capabilities
│   │   │   ├── cron_jobs.sh        # Cron job exploitation
│   │   │   ├── passwords.sh         # Password hunting
│   │   │   ├── cloud_container.sh   # Cloud/container escapes
│   │   │   └── network_process.sh   # Network processes
│   │   └── exploits/                 # Exploit suggestions
│   │       └── exploit_suggestions.sh
│   ├── windows/
│   │   └── privesc.ps1              # Windows PE checker (v2.0)
│   └── privilege-escalation.sh      # Legacy wrapper
│
├── 06-internal-recon/               # Phase 6: Post-compromise enumeration
│   ├── internal-recon-suite.sh      # Suite wrapper with menu
│   └── credentials/
│       └── creds.sh                  # Credential harvesting
│
├── 07-lateral-movement/             # Phase 7: Pivoting & lateral movement
│   └── lateral-suite.sh             # Suite wrapper with menu
│       ├── psexec.py                # psexec-style exploitation
│       ├── wmi_shell.py             # WMI-based shells
│       └── smb-relay.py             # SMB relay attacks
│
├── 08-persistence/                   # Phase 8: Maintaining access
│   └── persistence-suite.sh         # Suite wrapper with menu
│
├── 09-actions-objectives/           # Phase 9: Mission completion
│   ├── actions-suite.sh             # Suite wrapper with menu
│   ├── hashes/                      # Hash extraction/cracking
│   ├── logs/                        # Log analysis/clearing
│   └── stego/                       # Steganography tools
│
└── utils/                           # Utility scripts
    ├── parse.sh                     # Output parsing
    ├── parse-nmap.py                 # Nmap output parser
    ├── parse-nessus.py               # Nessus output parser
    ├── parse-burp.py                 # Burp Suite output parser
    └── *.py                          # Other utility parsers
```

## Usage

### Quick Start

```bash
# Launch main menu
./conductor.sh

# Run a specific phase directly
./01-reconnaissance/recon-suite.sh --menu
./05-privilege-escalation/linux/privesc.sh --quick

# Run individual scripts
./03-initial-compromise/payloads.sh
./03-initial-compromise/nikto.sh -h http://target.com
```

### Phase 1: Reconnaissance

Gather information about the target organization and systems.

```bash
./01-reconnaissance/recon-suite.sh --menu
# Options:
#   R1 - Domain information (whois, dig, nslookup)
#   R2 - DNS enumeration
#   R3 - Email harvesting (theHarvester, etc.)
#   R4 - Subdomain discovery
#   R7 - Network discovery (ping sweep)
```

### Phase 2: Enumeration & Vulnerability

Identify open ports, services, and vulnerabilities.

```bash
./02-enumeration-vulnerability/enum-suite.sh --menu
# Options:
#   E1-E5 - Port scanning (quick, full, version detection, OS, UDP)
#   EV1 - Nikto web scanner
#   EV2 - SSL/TLS analysis
#   EV3 - Directory busting
#   EV4 - CVE vulnerability scanning
```

### Phase 3: Initial Compromise

Exploit vulnerabilities to gain initial access.

```bash
./03-initial-compromise/compromise-suite.sh --menu
# Options:
#   C1 - Payload generation (msfvenom)
#   C2 - Reverse shell generator
#   C4 - Encoding & obfuscation
#   CW1 - Web exploitation toolkit
#   CB1 - ELF binary analyzer
#   CB2 - Fuzzer
```

### Phase 4: Establish Foothold

Stabilize shells and set up persistent listeners.

```bash
./04-establish-foothold/foothold-suite.sh --menu
```

### Phase 5: Privilege Escalation

Escalate privileges on compromised systems.

**Linux:**
```bash
./05-privilege-escalation/linux/privesc.sh --quick          # Quick scan
./05-privilege-escalation/linux/privesc.sh --json          # JSON output
./05-privilege-escalation/linux/privesc.sh --stealth       # Stealth mode
./05-privilege-escalation/linux/privesc.sh -s              # System info only
./05-privilege-escalation/linux/privesc.sh -p              # Permissions only
```

**Windows:**
```bash
./05-privilege-escalation/windows/privesc.ps1 -Quick        # Quick scan
./05-privilege-escalation/windows/privesc.ps1 -Verbose     # Verbose output
./05-privilege-escalation/windows/privesc.ps1 -Extended    # Extended checks
```

### Phase 6: Internal Recon

Post-compromise enumeration of the internal network.

```bash
./06-internal-recon/internal-recon-suite.sh --menu
```

### Phase 7: Lateral Movement

Pivot through the network to access other systems.

```bash
./07-lateral-movement/lateral-suite.sh --menu
```

### Phase 8: Persistence

Establish persistent access on compromised systems.

```bash
./08-persistence/persistence-suite.sh --menu
```

### Phase 9: Actions on Objectives

Complete the penetration test mission.

```bash
./09-actions-objectives/actions-suite.sh --menu
# Options:
#   O1 - Data exfiltration simulation
#   O2 - Hash dumping
#   O3 - Evidence collection
```

## Key Features

### Privilege Escalation Tools (v2.0)

The framework includes comprehensive privilege escalation tools:

**Linux privesc.sh Features:**
- Modular architecture with 10+ check modules
- Color-coded severity levels (Critical/High/Medium/Low)
- JSON output support for automation (`--json`)
- Stealth mode for OPSEC considerations (`--stealth`)
- Cloud metadata detection (AWS/Azure/GCP)
- Container escape techniques (Docker/Kubernetes)
- GTFOBins integration
- Metasploit module suggestions

**Windows privesc.ps1 Features:**
- AlwaysInstallElevated exploitation
- Unquoted service paths
- Stored credentials (cmdkey, vault)
- DLL hijacking
- Print Spooler (PrintNightmare)
- Windows Defender/AMSI status
- WMI event subscriptions
- GPP password detection
- Browser credentials extraction
- PowerShell history analysis
- Interesting privileges (SeImpersonate, SeDebug, etc.)

### Suite Wrapper Scripts

Each phase includes a `*-suite.sh` wrapper script with:
- Interactive menu interface
- Direct script execution options
- Help documentation
- Colored output

### Utility Scripts

The `utils/` directory contains:
- Output parsers for various tools (Nmap, Nessus, Burp, etc.)
- Report generation helpers
- Data conversion tools

## Best Practices

1. **Legal Authorization**: Always ensure you have written authorization before testing
2. **OPSEC**: Use `--stealth` mode when avoiding detection
3. **Documentation**: Use `--json` output for automated documentation
4. **Scope**: Stay within the agreed-upon scope
5. **Reporting**: Document all findings with timestamps and evidence

## Requirements

- Linux/macOS (most scripts)
- Kali Linux or similar penetration testing distribution
- Common tools: nmap, msfvenom, nikto, burp-suite, etc.
- For Windows scripts: PowerShell 5.0+

## License

This framework is provided for educational and authorized testing purposes only. Use responsibly.

## Contributing

When adding new scripts:
1. Place in appropriate phase directory
2. Create a suite wrapper if adding multiple related scripts
3. Update conductor.sh menu if needed
4. Add documentation comments
5. Test before committing
