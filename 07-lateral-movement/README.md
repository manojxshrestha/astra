# Phase 7: Lateral Movement

Pivot through the network to access other systems.

## Purpose

Move through the compromised network to:
- Access other systems
- Pivot through network segments
- Bypass network segmentation
- Establish additional compromised hosts

## Usage

```bash
# Interactive menu
./lateral-suite.sh --menu

# Direct options
./lateral-suite.sh L1 192.168.1.100
```

## Techniques

### Network Pivoting

| Script | Description |
|--------|-------------|
| `ssh-pivot.sh` | SSH tunneling for pivoting |
| ` portfwd.sh` | Local/remote port forwarding |
| `socat.sh` | Advanced pivoting with socat |

### Windows Lateral Movement

| Script | Description |
|--------|-------------|
| `psexec.py` | psexec-style exploitation |
| `wmiexec.py` | WMI-based command execution |
| `smbexec.py` | SMB command execution |
| `atexec.py` | Task scheduling via AT service |

### Credential Reuse

| Script | Description |
|--------|-------------|
| `hash-relay.py` | NTLM hash relay attacks |
| `credential-reuse.sh` | Reuse harvested credentials |

## Menu Options

- **L1**: psexec-style exploitation
- **L2**: WMI-based lateral movement
- **L3**: SMB exploitation
- **L4**: RDP hijacking
- **LW1**: WinRM exploitation
- **LW2**: Pass-the-Hash attacks
- **LW3**: Pass-the-Ticket (Kerberos)
- **LW4**: Golden Ticket attacks

## Common Techniques

### Linux
1. SSH pivoting with compromised keys
2. Rsync/rsync exploitation
3. NFS mounting
4. Docker/Kubernetes pivoting

### Windows
1. psexec/WMIExec
2. Pass-the-Hash
3. Pass-the-Ticket (Kerberos)
4. RDP hijacking
5. WinRM exploitation
6. SCCM exploitation

## Examples

```bash
# psexec exploitation
./lateral-suite.sh L1 target.local -u admin -p password

# WMI lateral movement
wmiexec.py domain/admin:password@target.local

# SSH pivoting
ssh -D 1080 user@compromised-host

# Port forwarding
ssh -L 3389:target:3389 user@pivot-host

# NTLM relay
ntlmrelayx.py -t smb://target.domain.local
```

## Notes

- Use harvested credentials for lateral movement
- Look for admin sessions to hijack
- Check for trusted relationships between systems
- Use pivoting chains for multi-segment access
- Consider implementing C2 over DNS/ICMP for restricted networks
