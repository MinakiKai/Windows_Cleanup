# Windows_Cleanup

Execute the following command in a powershell with admin privileges to Clean Temporary and useless files in Windows :

$folder="C:\HP2i_Windows_Cleanup"; New-Item -ItemType Directory -Path $folder -Force; Invoke-WebRequest -Uri "https://github.com/Username/Windows_Cleanup/raw/refs/heads/main/nettoyage_windows.ps1" -OutFile "$folder\Windows_Cleanup.ps1"; Unblock-File -Path "$folder\Windows_Cleanup.ps1"; & "$folder\Windows_Cleanup.ps1"; Start-Sleep -Seconds 5; Remove-Item -Path $folder -Recurse -Force
