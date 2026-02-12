# Wordlists

This directory contains wordlists used by PwnTheBox framework.

## Included Wordlists

| File | Size | Description |
|------|------|-------------|
| `common.txt` | 38KB | Common directory/file names |
| `rockyou.txt` | 134MB | Popular passwords list |

## Additional Wordlists

Add additional wordlists here as needed:

| File | Description |
|------|-------------|
| `directory.txt` | Directory/file names for busting |
| `http_default_userpass.txt` | HTTP default credentials |
| `common_passwords.txt` | Common passwords |
| `fuzzing.txt` | Fuzzing payloads |

## Installation

```bash
# Install from Kali packages
sudo apt install seclists

# Copy to framework wordlists
sudo cp /usr/share/wordlists/SecLists/* /home/pwn/pwnthebox/wordlists/
```
