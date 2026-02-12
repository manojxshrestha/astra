# Phase 4: Establish Foothold

Stabilize shells and set up persistent listeners.

## Purpose

Ensure reliable access to compromised systems:
- Shell stabilization techniques
- Reverse listener setup
- Session management
- Connection redundancy

## Usage

```bash
# Interactive menu
./foothold-suite.sh --menu
```

## Tools

| Script | Description |
|--------|-------------|
| `listener.sh` | Multi-platform reverse listener setup |
| `stabilizer.sh` | Shell stabilization techniques |

## Menu Options

- **F1**: Start Reverse Listener
- **F2**: Upgrade Shell to Meterpreter
- **F3**: Spawn PTY/Bash Shell
- **F4**: Background Session
- **F5**: Session Management
- **F6**: Configure Reverse Connection
- **F7**: SSL/TLS Listener
- **F8**: Multi-handler Setup
- **F9**: Check Active Sessions

## Examples

```bash
# Start multi-handler listener
./listener.sh

# Set up reverse connection
./listener.sh --lhost 192.168.1.100 --lport 443

# SSL encrypted listener
./listener.sh --ssl --lport 8443
```

## Shell Stabilization Techniques

1. **Python PTY Spawn**: `python -c 'import pty; pty.spawn("/bin/bash")'`
2. **Expect Script**: Use expect for interactive shells
3. **Netcat Stabilization**: `python -c 'import pty; pty.spawn("/bin/sh")'`
4. **Metasploit Sessions**: Use meterpreter sessions

## Notes

- Always stabilize shells for reliable interaction
- Use SSL/TLS for encrypted C2 traffic
- Maintain multiple sessions for redundancy
- Document session IDs and access methods
