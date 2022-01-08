# Global Variables
$ADDomain = "ad.homelab.net" # Change as needed
$ErrorActionPreference= 'silentlycontinue'

Set-ExecutionPolicy -Scope MachinePolicy Unrestricted
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 # Allowing to download PS Module
# Windows Update
Write-Host "Do you want to update this machine via Windows Update?" -ForegroundColor Yellow -BackgroundColor Black
$WindowsUpdate = Read-host "Type Y to UPDATE, ELSE press any key to skip..."
while ($WindowsUpdate -eq "y") {
    Write-Host "`nPreparing machines for Windows Update..." -ForegroundColor Yellow -BackgroundColor Black
    if ($(Get-InstalledModule).Name -eq "PSWindowsUpdate") {
        Write-Host "`nPSWindowsUpdate module was found! Will try to update the module..." -ForegroundColor Yellow -BackgroundColor Black
        Get-InstalledModule -Name "PSWindowsUpdate" | Uninstall-Module -Force -ErrorAction SilentlyContinue `
            -InformationAction SilentlyContinue -WarningAction SilentlyContinue # Removes old PSWindowsUpdate module
        Install-Module -Name PSWindowsUpdate # Installs the latest PSWindowsUpdate module
    } 
    else {
        Write-Host "`nPSWindowsUpdate module not found! Getting the module..." -ForegroundColor Yellow -BackgroundColor Black
        Install-Module -Name PSWindowsUpdate # Installs PSWindowsUpdate Module
    }
    Start-Sleep 1
    Get-WindowsUpdate -AcceptAll -Install -IgnoreRebootRequired -IgnoreReboot
    Break
}
Write-Host "`nOnto the next step..." -ForegroundColor Green
Start-Sleep 2
# Rename Computer
Write-Host "`n`nDo you want to RENAME this computer?" -ForegroundColor Yellow -BackgroundColor Black
$RenameComputer = Read-host "Type Y to rename, else press any key to skip..."
while ($RenameComputer -eq "y") {
    Write-Host "!--Make sure computer name starts with a letter and does not contain spaces" -ForegroundColor Red -BackgroundColor Black
    Start-Sleep 1
    $NewComputerName = Read-Host "Enter computer name"
    Write-Host "`nRenamming computer..." -ForegroundColor Yellow -BackgroundColor Black
    Start-Sleep 1
    Rename-Computer -NewName $NewComputerName.Trim() # Renames the computer; removes any spaces from start and end of the name set by the user
    Break
}
Write-Host "`nOnto the next step..." -ForegroundColor Green
Start-Sleep 2
# Join to domain
Write-Host "`n`nDo you want to join this computer to domain?" -ForegroundColor Yellow -BackgroundColor Black
$RenameComputer = Read-host "Type Y to JOIN, else press any key to skip..."
while ($RenameComputer -eq "y") {
    Write-Host "Contacting $($ADDomain)..." -ForegroundColor Red -BackgroundColor Black
    if (Test-Connection -ComputerName $ADDomain -Count 1) {
        Write-Host "AD domain $($ADDomain) is reachable..." -ForegroundColor Yellow -BackgroundColor Black
        Start-Sleep 1
        Write-Host "This machine will be joined to $($ADDomain)..." -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "!--Make sure you have the right credentials." -ForegroundColor Red -BackgroundColor Black
        Start-Sleep 1
        Add-Computer -DomainName "$($ADDomain)" # Joins the machine to the domain
        Break
    }
    else {
        Write-Host "$($ADDomain) is unreachable..." -ForegroundColor Red -BackgroundColor Black
        Break
    }
}
Write-Host "`nOnto the next step..." -ForegroundColor Green
Start-Sleep 2
# Reboot Computer
Write-Host "`n`nDo you want to restart now?" -ForegroundColor Yellow -BackgroundColor Black
Start-Sleep 1
Write-Host "!--All document changes will be lost if not saved when rebooted" -ForegroundColor Red -BackgroundColor Black
Start-Sleep 1
$RestartNow = Read-Host "Type Y to RESTART, else press any key to skip..."
while ($RestartNow -eq "y") {
    Restart-Computer -Force
}
Write-Host "`nRestart skipped..."-ForegroundColor Yellow
Start-Sleep 2
Exit