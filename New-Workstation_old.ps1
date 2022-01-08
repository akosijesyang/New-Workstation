Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force -ErrorAction SilentlyContinue -InformationAction SilentlyContinue -WarningAction SilentlyContinue
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 # Allowing to download PS Module
if (Test-Connection -ComputerName 8.8.8.8 -Count 1) {
    Write-Host "Post configurations are needed..." -ForegroundColor Yellow -BackgroundColor Black
    Start-Sleep 2
    Write-Host "`nPreparing machines for Windows Update..." -ForegroundColor Yellow -BackgroundColor Black
    if ($(Get-InstalledModule).Name -eq "PSWindowsUpdate") {
        Write-Host "`nPSWindowsUpdate module was found! Will try to update the module..." -ForegroundColor Yellow -BackgroundColor Black
        Get-InstalledModule -Name "PSWindowsUpdate" | Uninstall-Module -Force # Removes old PSWindowsUpdate module
        Install-Module -Name PSWindowsUpdate # Installs the latest PSWindowsUpdate module
    } 
    else {
        Write-Host "`nPSWindowsUpdate module not found! Getting the module..." -ForegroundColor Yellow -BackgroundColor Black
        Install-Module -Name PSWindowsUpdate # Installs PSWindowsUpdate Module
    }
    Write-Host "`nDownloading...Installing updates..." -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "!--DO NOT REBOOT when asked after installing updates..." -ForegroundColor Red -BackgroundColor Black
    Get-WindowsUpdate -Install -AcceptAll # Installs all available updates
    Write-Host "`nRenamming computer..." -ForegroundColor Yellow -BackgroundColor Black
    $NewComputerName = Read-Host "Enter computer name"
    Rename-Computer -NewName $NewComputerName
    Write-Host ""
    $DomainJoin = Read-host "Type YES to join to domain, ELSE press any key..."
    if ($DomainJoin -eq "yes") {
        Write-Host "Joining machine into the domain..." -ForegroundColor Yellow -BackgroundColor Black
        Add-Computer -DomainName "ad.homelab.net" # Joins computer to the domain
        Start-Sleep 2
        Write-Host "Automatic restart..."
        Start-Sleep 2
        Restart-Computer -Force
    }
    else {
        Write-Host "`nJoining to domain skipped..." -ForegroundColor Yellow -BackgroundColor Black
        Start-Sleep 2
        Write-Host "Automatic restart..."
        Start-Sleep 2
        Restart-Computer -Force
    }
}
else {
    Write-Host "`nInternet connection is not detected!`n" -ForegroundColor Red -BackgroundColor Black
}
