# Windows_Cleanup

Execute the following command in a powershell with admin privileges to Clean Temporary and useless files in Windows :

powershell.exe -ExecutionPolicy Bypass -Command "& {New-Item -ItemType Directory -Path 'C:\Powershell_Windows_Cleanup' -Force | Out-Null; Invoke-WebRequest -Uri 'https://github.com/MinakiKai/Windows_Cleanup/raw/refs/heads/main/Windows_Cleanup.ps1' -OutFile 'C:\Powershell_Windows_Cleanup\Windows_Cleanup.ps1'; & 'C:\Powershell_Windows_Cleanup\Windows_Cleanup.ps1'}"
