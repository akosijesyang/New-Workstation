Set-ExecutionPolicy -Scope CurrentUser Unrestricted -ErrorAction SilentlyContinue `
    -InformationAction SilentlyContinue # Allows script to run without error
$ErrorActionPreference = 'silentlycontinue' # Hides error caused by Set-ExecutionPolicy

Write-Host "`n`n!--NOTE: Make sure you already modified the values in Global Variables`n`n" -ForegroundColor DarkYellow
Start-Sleep 2

# Global Variables
$ADDomain = "ad.homelab.net" # Change as needed
$RSATServer = 'RSAT-Clustering',
'RSAT-AD-Tools',
'RSAT-DHCP',
'RSAT-DNS-Server',
'GPMC' # Add server management tools as needed; use Get-WindowsFeature to discover
$RSAT = 'RSAT: DHCP Server Tools', 
'RSAT: DNS Server Tools',
'RSAT: Failover Clustering Tools',
'RSAT: Group Policy Management Tools',
'RSAT: Server Manager',
'RSAT: Active Directory Domain Services and Lightweight Directory Services Tools' # Add RSAT as needed; use Get-WindowsCapability to discover

Write-Host "Internet connectivity test..." -ForegroundColor Yellow -BackgroundColor Black
Start-Sleep 2
if (Test-Connection -ComputerName 8.8.8.8 -count 1) {
    Write-Host "!--PASSED: Connected to the Internet`n`n" -ForegroundColor Green
    # Windows Update
    Write-Host "Do you want to update this machine via Windows Update?" -ForegroundColor Yellow
    $WindowsUpdate = Read-host "Type Y to UPDATE, ELSE press any key to skip..."
    while ($WindowsUpdate -eq "y") {
        Write-Host "Preparing machines for Windows Update..."
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 # Allowing to download PS Module
        if ($(Get-InstalledModule).Name -eq "PSWindowsUpdate") {
            Write-Host "PSWindowsUpdate module was found! Will try to update the module..."
            Get-InstalledModule -Name "PSWindowsUpdate" | Uninstall-Module -Force -ErrorAction SilentlyContinue `
                -InformationAction SilentlyContinue -WarningAction SilentlyContinue # Removes old PSWindowsUpdate module
            Install-Module -Name PSWindowsUpdate # Installs the latest PSWindowsUpdate module
        } 
        else {
            Write-Host "PSWindowsUpdate module not found! Getting the module..."
            Install-Module -Name PSWindowsUpdate # Installs PSWindowsUpdate Module
        }
        Get-WindowsUpdate -AcceptAll -Install -IgnoreRebootRequired -IgnoreReboot
        Break
    }
    Write-Host "Onto the next step...`n" -ForegroundColor Yellow
    
    # Install Server Tools
    Write-Host "Do you want to install server tools (AD,GP,DNS,DHCP)?" -ForegroundColor Yellow
    $Install = Read-Host "Type Y to INSTALL, else press any key to skip..."
    while ($Install -eq "y") {
        Write-Host "Detecting OS type..."
        $OSDetection = Get-WmiObject -Class "Win32_OperatingSystem"
        if ($OSDetection.Caption -match "server") {
            Write-Host "Installing Server Management Tools for SERVER..."
            foreach ($tool in $RSATServer) {
                Get-WindowsFeature -Name $tool | Where-Object {$PSItem.Name -eq $tool -and $PSItem.Installed `
                    -ne "Installed"} | Install-WindowsFeature -IncludeAllSubFeature
            } 
            Break
        }
        else {
            Write-Host "Installing RSAT for WORKSTATION..."

            foreach ($tool in $RSAT) {
                Get-WindowsCapability -Name *RSAT* -Online | Where-Object { $PSItem.DisplayName -eq $tool `
                        -and $PSItem.State -eq "NotPresent" } | Add-WindowsCapability -Online
            }
            Break
        }
    }
    Write-Host "Onto the next step...`n" -ForegroundColor Yellow

    # Join to domain and rename computer
    Write-Host "Do you want to RENAME this computer and JOIN to a domain?" -ForegroundColor Yellow
    $RenamexJoinComputer = Read-host "Type Y to RENAME & JOIN, else press any key to skip..."
    while ($RenamexJoinComputer -eq "y") {
            Write-Host "Contacting $($ADDomain)..." -ForegroundColor Yellow -BackgroundColor Black
            if (Test-Connection -ComputerName $ADDomain -Count 1) {
                Write-Host "AD domain $($ADDomain) is reachable..." -ForegroundColor Green
                Write-Host "This machine will be joined to $($ADDomain)..."
                Write-Host "!--New name SHOULD NOT: (a) begin with a number (b) have space nor special character" -ForegroundColor Red -BackgroundColor Black
                Write-Host "!--New name with more than 14 characters will be automatically trimmed" -ForegroundColor Red -BackgroundColor Black
                Write-Host "!--Make sure you have the right credentials" -ForegroundColor Red -BackgroundColor Black
                $NewName = Read-Host "Enter computer name"
                $InvalidBeginningCharacter = '0','1','2','3','4','5','6','7','8','9','.','\','/',':','*','"','<','>','|',',','~','!','@','#','$','%','^','&','(',')','{','}','_',';',' '
                $InvalidCharacters = '.','\','/',':','*','"','<','>','|',',','~','!','@','#','$','%','^','&','(',')','{','}','_',';',' '
                while ($NewName[0] -in $InvalidBeginningCharacter -or $NewName -eq ""-or $NewName -contains $InvalidCharacters) {
                    Write-Host "!--New name SHOULD NOT: (a) begin with a number (b) have space nor special character" -ForegroundColor Red -BackgroundColor Black
                    Write-Host "!--New name with more than 14 characters will be automatically trimmed" -ForegroundColor Red -BackgroundColor Black
                    $NewName = Read-Host "Enter a VALID computer name"
                }
                if ($NewName.Length -gt 14) {
                    $NewName.Trim() # Clears white spaces from beginning and end
                    $TrimmedNewName = $NewName.Remove(14) # Remove extra characters
                    Write-Host "Computer name was trimmed to $($TrimmedNewName)"
                }
                Add-Computer -NewName $TrimmedNewName -DomainName $($ADDomain) -Credential (Get-Credential -Message `
                        "FORMAT: domain\account" -ErrorAction Stop) # Joins the machine to the domain
            }
            else {
                Write-Host "$($ADDomain) is unreachable..." -ForegroundColor Red
                Break
            }
        Break
    }
    Write-Host "Onto the next step...`n" -ForegroundColor Yellow

    # Reboot Computer
    Write-Host "Do you want to restart now?" -ForegroundColor Yellow
    Write-Host "!--All document changes will be lost if not saved when rebooted" -ForegroundColor Red -BackgroundColor Black
    $RestartNow = Read-Host "Type Y to RESTART, else press any key to skip..."
    while ($RestartNow -eq "y") {
        Start-Sleep 2
        Restart-Computer -Force
    }
    Write-Host "Restart skipped..." -ForegroundColor Yellow
    Start-Sleep 2
    Write-Host "Exiting..." -ForegroundColor Yellow
    Exit
}
else {
    Write-host "!--FAILED: Machine is not connected to the Internet." -ForegroundColor Red
    Write-Host "Connect to the Internet and try again"
    Start-Sleep 2
    Write-Host "Exiting..." -ForegroundColor Yellow
    Exit
}