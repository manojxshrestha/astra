# Phase 8: Persistence

Establish persistent access on compromised systems.

## Purpose

Maintain access to compromised systems:
- Backdoor installation
- Scheduled task creation
- Service installation
- Account manipulation
- Boot persistence

## Usage

```bash
# Interactive menu
./persistence-suite.sh --menu

# Direct options
./persistence-suite.sh P1
```

## Techniques

### Linux Persistence

| Script | Description |
|--------|-------------|
| `cron-backdoor.sh` | Cron job-based backdoor |
| `ssh-backdoor.sh` | SSH key injection |
| `systemd-backdoor.sh` | Service-based persistence |
| `bash-history.sh` | Command history manipulation |

### Windows Persistence

| Script | Description |
|--------|-------------|
| `schtasks-persistence.ps1` | Scheduled task creation |
| `service-persistence.ps1` | Service installation |
| `registry-persistence.ps1` | Registry run keys |
| `wmi-subscription.ps1` | WMI event subscriptions |
| `dll-hijack-persistence.ps1` | DLL hijacking |

## Menu Options

- **P1**: Cron/Scheduled Task Backdoor
- **P2**: SSH/Remote Desktop Keys
- **P3**: Service Installation
- **P4**: Web Shell Installation
- **P5**: Boot Persistence
- **PW1**: Registry Run Keys
- **PW2**: Winlogon Helper
- **PW3**: Browser Extensions
- **PW4**: Accessibility Tools
- **PW5**: COM Hijacking

## Common Techniques

### Linux
1. Cron jobs with reverse shells
2. SSH authorized_keys injection
3. systemd/Init service creation
4. PAM manipulation
5. inetd/xinetd configuration
6. LD_PRELOAD shared libraries

### Windows
1. Registry Run keys
2. Scheduled Tasks
3. Windows Services
4. Startup Folder
5. Winlogon Shell
6. Userinit/Shell
7. Accessibility Tools (Sticky Keys)
8. Image File Execution Options
9. WMI Event Subscriptions
10. DLL Search Order Hijacking

## Examples

```bash
# Create cron-based backdoor
./persistence-suite.sh P1

# SSH key injection
ssh-persistence.sh --inject

# Scheduled task persistence
schtasks /create /tn "Windows Update" /sc minute /mo 30 /tr "reverse_shell.exe"

# Registry persistence
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Update" /t REG_SZ /d "backdoor.exe"
```

## Notes

- Use reliable, low-detection persistence methods
- Consider using multiple persistence mechanisms
- Use encrypted channels for persistence callbacks
- Document all persistence mechanisms installed
- Consider using domain-level persistence when possible
- Have a backup access method in case of discovery
