Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
Write-Host "Post configurations are needed..." -ForegroundColor Yellow
Start-Sleep 2
Write-Host "Joining machine into the domain..." -ForegroundColor Yellow
$NewComputerName = Read-Host "Enter computer name"
Rename-Computer -NewName $NewComputerName
Add-Computer -DomainName "ad.homelab.net" # Joins computer to the domain
Restart-Computer -Force