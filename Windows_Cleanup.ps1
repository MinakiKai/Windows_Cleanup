#  Version 2.0 date : 12/03/25
#  Vérification de l’espace disque AVANT nettoyage
$diskBefore = Get-PSDrive C
$freeBefore = $diskBefore.Free / 1GB
Write-Host " Espace disque AVANT nettoyage : $freeBefore GB"
Write-Host "-------------------------"

#  Étape 1 : Arrêt du service Windows Update
Write-Host "Etape 1 : Arret du service Windows Update..."
Stop-Service -Name wuauserv -Force
Start-Sleep -Seconds 2
Write-Host " Service Windows Update stop."
Write-Host "-------------------------"

#  Étape 2 : Suppression des fichiers Windows Update inutiles
Write-Host "Etape 2 : Suppression des fichiers de mises à jour inutiles..."
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host " Fichiers Windows Update delete."
Write-Host "-------------------------"

#  Étape 3 : Redémarrage du service Windows Update
Write-Host "Etape 3 : Redemarrage du service Windows Update..."
Start-Service -Name wuauserv
Start-Sleep -Seconds 2
Write-Host " Service Windows Update reboot."
Write-Host "-------------------------"

#  Étape 4 : Nettoyage du dossier WinSxS (peut prendre du temps)
Write-Host "Etape 4 : Nettoyage du dossier WinSxS... (Patientez)"
Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
Write-Host " Nettoyage WinSxS fini."
Write-Host "-------------------------"

#  Étape 5 : Suppression des fichiers temporaires Windows
Write-Host "Etape 5 : Suppression des fichiers temporaires..."
if (Test-Path "C:\Windows\Temp\*") {
    Get-ChildItem -Path "C:\Windows\Temp\*" -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Aucun fichier temporaire dans C:\Windows\Temp"
}

if (Test-Path "$env:TEMP\*") {
    Get-ChildItem -Path "$env:TEMP\*" -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Aucun fichier temporaire dans $env:TEMP"
}
Write-Host " Fichiers temporaires delete."
Write-Host "-------------------------"

#  Étape 6 : Lancement du Nettoyage de disque en arrière-plan
Write-Host "Etape 6 : Lancement du Nettoyage de disque..."
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -NoNewWindow -Wait
Write-Host " Nettoyage de disque terminé."
Write-Host "-------------------------"

#  Étape 7 : Supprimer dans la corbeille tout ce qui est vieux de + d'un an
$limitDate = (Get-Date).AddYears(-1)
$recycleBinPath = "$env:SystemDrive\`$Recycle.Bin\"

if (Test-Path $recycleBinPath) {
    $oldFiles = Get-ChildItem -Path $recycleBinPath -Recurse -Force | Where-Object { $_.LastWriteTime -lt $limitDate }
    if ($oldFiles.Count -gt 0) {
        Write-Host "Suppression des fichiers de plus d'un an..."
        $oldFiles | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Fichiers de plus d'un an supprimés de la corbeille."
    } else {
        Write-Host "Aucun fichier de plus d'un an trouve dans la corbeille."
    }
} else {
    Write-Host "La corbeille est vide ou introuvable."
}
Write-Host "-------------------------"

#  Étape 8 : Vérification et réduction de la taille de Windows.edb
Write-Host "Etape 8 : Verification de la taille de Windows.edb (fichier indexation Windows)..."
$edbPath1 = "C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb"
$edbPath2 = "C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.db"

if (Test-Path $edbPath1) {
    Get-ChildItem $edbPath1 | Select-Object FullName, Length
} elseif (Test-Path $edbPath2) {
    Get-ChildItem $edbPath2 | Select-Object FullName, Length
} else {
    Write-Host "Windows.edb ou Windows.db introuvable."
}
Write-Host "-------------------------"

#  Réduction de la taille de Windows.edb
Write-Host "Reduction de la taille de Windows.edb..."
Set-Service WSearch -StartupType Disabled
Stop-Service WSearch -Force
Start-Sleep -Seconds 5
Write-Host "Service Windows Search stop."

if (Test-Path $edbPath1) {
    Remove-Item $edbPath1 -Force -ErrorAction Stop
    Write-Host "Windows.edb delete."
} elseif (Test-Path $edbPath2) {
    Remove-Item $edbPath2 -Force -ErrorAction Stop
    Write-Host "Windows.db delete."
} else {
    Write-Host "Aucun fichier a supprimer."
}

Set-Service WSearch -StartupType Automatic
if (-not (Get-Service WSearch -ErrorAction SilentlyContinue)) {
    Start-Service WSearch
    Start-Sleep -Seconds 2
    Write-Host "Service Windows Search reboot."
}
Write-Host "-------------------------"

# Vérification de l’espace disque APRÈS nettoyage
$diskAfter = Get-PSDrive C
$freeAfter = $diskAfter.Free / 1GB
$gain = [math]::Round($freeAfter - $freeBefore, 2)

Write-Host "--- Espace disque APRES nettoyage : $freeAfter GB ---"
Write-Host "--- Gain d espace total : $gain GB ---"

Write-Host "Nettoyage fini avec succes ! "

# Suppression du dossier de nettoyage
Write-Host "Cleaning up the script folder..."
Remove-Item -Path "C:\HP2i_Windows_Cleanup" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Le dossier contenant le script a été supprimé"
