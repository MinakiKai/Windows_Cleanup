# Windows_Cleanup

Execute the following command in a powershell with admin privileges to Clean Temporary and useless files in Windows :

powershell.exe -ExecutionPolicy Bypass -Command "& {New-Item -ItemType Directory -Path 'C:\HP2i_Windows_Cleanup' -Force | Out-Null; Invoke-WebRequest -Uri 'ttps://github.com/Username/Windows_Cleanup/raw/refs/heads/main/Windows_Cleanup.ps1' -OutFile 'C:\HP2i_Windows_Cleanup\Windows_Cleanup.ps1'; & 'C:\HP2i_Windows_Cleanup\Windows_Cleanup.ps1'}"
