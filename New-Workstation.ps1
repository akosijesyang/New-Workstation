Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force -ErrorAction SilentlyContinue -InformationAction SilentlyContinue -WarningAction SilentlyContinue
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 # Allowing to download PS Module
if (Test-Connection -ComputerName 8.8.8.8 -Count 1) {
    Write-Host "Post configurations are needed..." -ForegroundColor Yellow
    Start-Sleep 2
    Write-Host "`nPreparing machines for Windows Update..." -ForegroundColor Yello
    if ($(Get-InstalledModule).Name -eq "PSWindowsUpdate") {
        Write-Host "`nPSWindowsUpdate module was found! Will try to update the module..." -ForegroundColor Yellow
        Update-WUModule -Online -ErrorAction SilentlyContinue
    } 
    else {
        Write-Host "`nPSWindowsUpdate module not found! Getting the module..." -ForegroundColor Yellow
        Install-Module -Name PSWindowsUpdate -AcceptLicense -Force # Installs PSWindowsUpdate Module
    }
    Write-Host "`nDownloading...Installing updates..." -ForegroundColor Yellow
    Get-WindowsUpdate -Install -AcceptAll # Installs all available updates
    Write-Host "`nRenamming computer..." -ForegroundColor Yellow
    $NewComputerName = Read-Host "Enter computer name"
    Rename-Computer -NewName $NewComputerName
    $DomainJoin = Read-host "Type YES to join to domain, ELSE press any key..."
    if ($DomainJoin -eq "yes") {
        Write-Host "Joining machine into the domain..." -ForegroundColor Yellow
        Add-Computer -DomainName "ad.homelab.net" # Joins computer to the domain
        Start-Sleep 2
        Write-Host "Automatic restart..."
        Start-Sleep 2
        Restart-Computer -Force
    }
    else {
        Write-Host "`nJoining to domain skipped..." -ForegroundColor Yellow
        Start-Sleep 2
        Write-Host "Automatic restart..."
        Start-Sleep 2
        Restart-Computer -Force
    }
}
else {
    Write-Host "`nInternet connection is not detected!`n" -ForegroundColor Red
}
