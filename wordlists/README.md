# Wordlists

This directory contains wordlists used by PwnTheBox framework.

## Included Wordlists

| File | Description |
|------|-------------|
| `common.txt` | Common directory/file names (user-provided) |

## Placeholder Wordlists

The following wordlists are referenced by the framework but not included (install from Kali packages):

| File | Install Command |
|------|---------------|
| `rockyou.txt` | `apt install wordlists` |
| `http_default_userpass.txt` | `apt install seclists` |
| `directory.txt` | `apt install seclists` |
| `common_passwords.txt` | `apt install seclists` |
| `fuzzing.txt` | `apt install seclists` |

## Installation

```bash
# Install full wordlists
sudo apt install wordlists seclists

# Copy to framework wordlists directory
sudo cp /usr/share/wordlists/rockyou.txt /home/pwn/pwnthebox/wordlists/
sudo cp /usr/share/wordlists/SecLists/* /home/pwn/pwnthebox/wordlists/
```
