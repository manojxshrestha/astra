# Phase 5: Privilege Escalation

Escalate privileges on compromised systems to gain higher access levels.

## Purpose

Local privilege escalation to achieve:
- Administrator/root access
- Service account compromise
- Credential harvesting
- Domain admin access (Windows)

## Usage

### Linux

```bash
# Interactive menu
./linux/privesc.sh --menu

# Quick scan
./linux/privesc.sh --quick

# JSON output for reporting
./linux/privesc.sh --json

# Stealth mode (OPSEC)
./linux/privesc.sh --stealth

# Specific checks
./linux/privesc.sh -s              # System info only
./linux/privesc.sh -p              # Permissions only
./linux/privesc.sh -n              # Network info only
./linux/privesc.sh -u              # User info only
./linux/privesc.sh -c              # Cron jobs only
```

### Windows

```powershell
# PowerShell execution
powershell -ep bypass -f windows/privesc.ps1

# Options
-Quick         # Quick scan
-Verbose       # Verbose output
-Extended      # Extended checks
-All           # Full system scan
-Json          # JSON output
-Report        # Generate HTML report
```

## Linux Tools

### Check Modules

| Script | Description |
|--------|-------------|
| `checks/system_info.sh` | System information gathering |
| `checks/suid_sgid.sh` | SUID/SGID binary exploitation |
| `checks/capabilities.sh` | Linux capabilities abuse |
| `checks/cron_jobs.sh` | Cron job exploitation |
| `checks/passwords.sh` | Password hunting |
| `checks/cloud_container.sh` | Cloud/container escape |
| `checks/network_process.sh` | Network process analysis |

### Exploit Suggestions

| Script | Description |
|--------|-------------|
| `exploits/exploit_suggestions.sh` | Privilege escalation exploits |

## Windows Privilege Escalation

The `privesc.ps1` script checks for:

- **AlwaysInstallElevated**: Misconfigured installer policy
- **Unquoted Service Paths**: Service binary hijacking
- **Stored Credentials**: Saved credentials discovery
- **DLL Hijacking**: Missing DLL exploitation
- **Print Spooler**: PrintNightmare vulnerabilities
- **Windows Defender**: AV status and bypass
- **WMI Event Subscriptions**: Persistence and execution
- **GPP Passwords**: Group Policy stored credentials
- **Browser Credentials**: Chrome credential theft
- **PowerShell History**: Command history analysis
- **Interesting Privileges**: SeImpersonate, SeDebug, etc.

## Severity Levels

- **CRITICAL**: Immediate root/admin access possible
- **HIGH**: High probability of escalation
- **MEDIUM**: Potential escalation path
- **LOW**: Informational findings

## Common Exploitation Paths

### Linux
1. SUID binaries with GTFOBins
2. Writable /etc/passwd
3. Cron job exploitation
4. Sudo rights abuse
5. NFS no_root_squash
6. Docker container escape

### Windows
1. AlwaysInstallElevated
2. Unquoted service paths
3. Stored credentials
4. DLL hijacking
5. Print Spooler
6. Token impersonation

## Examples

```bash
# Quick Linux privilege escalation check
./linux/privesc.sh --quick

# Full scan with JSON output
./linux/privesc.sh --json > privesc_report.json

# Check for SUID binaries
./linux/privesc.sh -p

# Stealth mode (avoid detection)
./linux/privesc.sh --stealth
```

## Notes

- Always check for kernel exploits first
- Look for credential reuse opportunities
- Check for container isolation escapes
- Use stealth mode during red team engagements
- Document all escalation paths found
