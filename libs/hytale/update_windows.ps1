[CmdletBinding()]
param(
    [Parameter()]
    [string]$Destination
)

$scriptDir = $PSScriptRoot

function Resolve-ServerRoot {
    param(
        [string]$BaseDir,
        [string]$ExplicitDestination
    )

    if ($ExplicitDestination) {
        return (Resolve-Path -Path $ExplicitDestination).Path
    } else {
        return Join-Path $ScriptDir "win-server"
    }
}

$serverRoot = Resolve-ServerRoot -BaseDir $scriptDir -ExplicitDestination $Destination
New-Item -ItemType Directory -Force -Path $serverRoot
$downloader = Join-Path $scriptDir "hytale-downloader-windows-amd64.exe"
$downloaderTemp = $null

$tempRoot = Join-Path $env:TEMP ("hytale-update-" + [guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $tempRoot "game.zip"
$extractDir = Join-Path $tempRoot "unpacked"
$versionFile = Join-Path $serverRoot "last_version.txt"

New-Item -ItemType Directory -Path $tempRoot | Out-Null

try {
    if (-not (Test-Path $downloader)) {
        Write-Host "Updater not found, fetching latest..."
        $downloaderTemp = Join-Path $env:TEMP ("hytale-downloader-" + [guid]::NewGuid().ToString("N"))
        New-Item -ItemType Directory -Path $downloaderTemp | Out-Null
        $downloaderZip = Join-Path $downloaderTemp "hytale-downloader.zip"
        Invoke-WebRequest -Uri "https://downloader.hytale.com/hytale-downloader.zip" -OutFile $downloaderZip
        Expand-Archive -Path $downloaderZip -DestinationPath $downloaderTemp -Force

        $downloadedExe = Get-ChildItem -Path $downloaderTemp -Recurse -Filter "hytale-downloader-windows-amd64.exe" | Select-Object -First 1
        if (-not $downloadedExe) {
            throw "Downloader not found in archive."
        }
        Copy-Item -Path $downloadedExe.FullName -Destination $downloader -Force
    }

    ## Get newversion value
    $newVersion = $null
    $output = cmd /c $downloader -check-update
    Write-Host "Output: || $output ||"
    if (-not $newVersion -and $output -match '([0-9]+\.[0-9]+\.[0-9]+\-[0-9a-zA-Z]+)') {
        $newVersion = $Matches[1].Trim()
        Write-Host "Available version: $newVersion"
    }

    if ($newVersion) {
        $oldVersion = $null
        if (Test-Path -Path $versionFile) {
            $oldVersion = Get-Content $versionFile -Raw
            Write-Host "Current version: $oldVersion"
        }
        if ($newVersion -eq $oldVersion) {
            Write-Host "Up to date: ($newVersion). Exiting."
            return
        }
    }
    
    Write-Host "Downloading..."
    & $downloader -download-path $zipPath 2>&1

    Write-Host "Extracting..."
    New-Item -ItemType Directory -Path $extractDir | Out-Null
    Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

    Write-Host "Updating..."

    robocopy $extractDir $serverRoot /s
    # Get-ChildItem -Path $extractDir -Recurse | ForEach-Object {        
    #     $dest = $serverRoot + $_.FullName.SubString($extractDir.Length)
    #     $dest = Join-Path $dest ..

    #     if (!($dest.Contains('.')) -and !(Test-Path $dest)) {

    #         mkdir $dest
    #     }

    #     Copy-Item $_.FullName -Destination $dest -Force
    # }

    if ($newVersion) {
        Set-Content -Path $versionFile -Value $newVersion -NoNewline
    }

    Write-Host "Update Complete."
}
finally {
    if ($downloaderTemp -and (Test-Path $downloaderTemp)) {
        Remove-Item -Path $downloaderTemp -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path $tempRoot) {
        Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}