param([switch]$Uninstall, [string]$GameDirectory, [string]$ArchivePath)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Set-IniValue {
    param([string]$Text, [string]$Section, [string]$Key, [string]$Value)
    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in ($Text -split '\r?\n')) { $lines.Add($line) }
    $sectionStart = -1
    $sectionEnd = $lines.Count
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index].Trim() -ieq "[$Section]") { $sectionStart = $index; break }
    }
    if ($sectionStart -lt 0) {
        $lines.Add("[$Section]")
        $lines.Add("$Key=$Value")
    } else {
        for ($index = $sectionStart + 1; $index -lt $lines.Count; $index++) {
            if ($lines[$index] -match '^\s*\[') { $sectionEnd = $index; break }
        }
        for ($index = $sectionEnd - 1; $index -gt $sectionStart; $index--) {
            if ($lines[$index] -match ('^\s*' + [regex]::Escape($Key) + '\s*=')) {
                $lines.RemoveAt($index)
                $sectionEnd--
            }
        }
        $lines.Insert($sectionEnd, "$Key=$Value")
    }
    return ($lines -join "`r`n")
}

function Get-SafePath {
    param([string]$Root, [string]$Relative)
    if ([IO.Path]::IsPathRooted($Relative)) { throw 'Unexpected absolute file path.' }
    $rootFull = [IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    $full = [IO.Path]::GetFullPath((Join-Path $rootFull $Relative))
    if (!$full.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Unexpected file path outside the selected folder.'
    }
    $current = $full
    while ($current.Length -ge $rootFull.TrimEnd('\').Length) {
        if (Test-Path -LiteralPath $current) {
            if ((Get-Item -LiteralPath $current -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
                throw "Linked paths are not supported: $current"
            }
        }
        $current = Split-Path -Parent $current
        if (!$current) { break }
    }
    return $full
}

function Assert-ModFile {
    param([string]$Relative)
    if ($Relative -match '(^|[\\/])\.\.([\\/]|$)' -or $Relative.Contains(':')) {
        throw "Unexpected mod file path: $Relative"
    }
    if ($Relative -notin @('dxgi.dll', 'Luma-Watch Dogs 2.addon', 'nvngx_dlss.dll') -and
        $Relative -notmatch '^Luma[\\/]') { throw "Unexpected mod file: $Relative" }
}

try {
    if (Get-Process -Name WatchDogs2 -ErrorAction SilentlyContinue) {
        throw 'Close Watch Dogs 2 first, then run this installer again.'
    }
    if (!$GameDirectory) {
        $picker = New-Object System.Windows.Forms.FolderBrowserDialog
        $picker.Description = 'Select your Watch Dogs 2 game folder (or its bin folder)'
        $picker.ShowNewFolderButton = $false
        if ($picker.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { exit 0 }
        $GameDirectory = $picker.SelectedPath
        $picker.Dispose()
    }
    $bin = [IO.Path]::GetFullPath($GameDirectory).TrimEnd('\')
    if (!(Test-Path -LiteralPath (Join-Path $bin 'WatchDogs2.exe'))) { $bin = Join-Path $bin 'bin' }
    if (!(Test-Path -LiteralPath (Join-Path $bin 'WatchDogs2.exe') -PathType Leaf)) {
        throw 'This folder does not contain bin\WatchDogs2.exe. Select the actual game installation.'
    }
    $backup = Get-SafePath $bin 'WD2-Luma-Installer-Backup'
    $manifestPath = Get-SafePath $backup 'installed.json'
    $configPath = Get-SafePath $bin 'ReShade.ini'
    $originalPath = Get-SafePath $backup 'ReShade.original.ini'
    if ($Uninstall) {
        if (!(Test-Path -LiteralPath $manifestPath)) { throw 'No installation record from this installer was found.' }
        $record = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
        if ($record.Bin -ine $bin) { throw 'The installation record belongs to a different folder.' }
        if ($record.HadConfig -and !(Test-Path -LiteralPath $originalPath -PathType Leaf)) { throw 'Original configuration backup is missing. Nothing removed.' }
        $targets = @($record.Files | ForEach-Object {
            Assert-ModFile $_.Relative
            [pscustomobject]@{ Path = (Get-SafePath $bin $_.Relative); Hash = $_.Hash }
        })
        foreach ($target in $targets) {
            if (Test-Path -LiteralPath $target.Path -PathType Leaf) {
                if ((Get-FileHash -LiteralPath $target.Path -Algorithm SHA256).Hash -eq $target.Hash) {
                    Remove-Item -LiteralPath $target.Path
                } else { Write-Host "Kept modified file: $($target.Path)" }
            }
        }
        if (Test-Path -LiteralPath $configPath) {
            Copy-Item -LiteralPath $configPath -Destination (Join-Path $backup ('ReShade-before-uninstall-' + [guid]::NewGuid() + '.ini'))
        }
        if ($record.HadConfig) { Copy-Item -LiteralPath $originalPath -Destination $configPath -Force }
        elseif (Test-Path -LiteralPath $configPath) { Remove-Item -LiteralPath $configPath }
        Move-Item -LiteralPath $manifestPath -Destination (Join-Path $backup ('uninstalled-' + [guid]::NewGuid() + '.json'))
        Write-Host 'Uninstalled. Backups and modified mod files, if any, remain.'
        exit 0
    }
    if (Test-Path -LiteralPath $backup) { throw 'A backup already exists. Uninstall/review the existing setup first; it will not be overwritten.' }
    $temporary = Join-Path ([IO.Path]::GetTempPath()) ('WD2-Luma-' + [guid]::NewGuid())
    New-Item -ItemType Directory -Path $temporary | Out-Null
    $archive = Join-Path $temporary 'Luma.zip'
    if ($ArchivePath) { Copy-Item -LiteralPath $ArchivePath -Destination $archive }
    else {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Host 'Downloading official Luma Watch Dogs 2 (about 36 MB)...'
        Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/Filoppi/Luma-Framework/releases/download/latest-722/Luma-Watch_Dogs_2.zip' -OutFile $archive -TimeoutSec 180
    }
    $expected = '35c3e100f909fab9d0a975a57bbdf46b6f6bf6c9268d5385c1e449f8aaacfa48'
    if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ine $expected) { throw 'Download checksum mismatch. Nothing has been installed.' }
    $payload = Join-Path $temporary 'payload'
    $zip = [IO.Compression.ZipFile]::OpenRead($archive)
    try { foreach ($entry in $zip.Entries) { $null = Get-SafePath $payload $entry.FullName } }
    finally { $zip.Dispose() }
    [IO.Compression.ZipFile]::ExtractToDirectory($archive, $payload)
    $files = @(Get-ChildItem -LiteralPath $payload -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($payload.Length + 1)
        Assert-ModFile $relative
        $destination = Get-SafePath $bin $relative
        if (Test-Path -LiteralPath $destination) { throw "Existing mod file: $relative. Nothing has been installed." }
        [pscustomobject]@{ Relative = $relative; Hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash }
    })
    foreach ($required in @('dxgi.dll', 'Luma-Watch Dogs 2.addon', 'nvngx_dlss.dll')) {
        if ($required -notin $files.Relative) { throw "Missing package file: $required" }
    }
    New-Item -ItemType Directory -Path $backup | Out-Null
    $hadConfig = Test-Path -LiteralPath $configPath -PathType Leaf
    $config = ''
    if ($hadConfig) {
        Copy-Item -LiteralPath $configPath -Destination $originalPath
        $config = [IO.File]::ReadAllText($configPath)
    }
    [ordered]@{ Bin = $bin; HadConfig = $hadConfig; Files = $files; Release = 'latest-722' } |
        ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
    foreach ($file in $files) {
        $destination = Get-SafePath $bin $file.Relative
        New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $payload $file.Relative) -Destination $destination
        if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $file.Hash) { throw "Copy verification failed: $($file.Relative)" }
    }
    $config = Set-IniValue $config 'INPUT' 'KeyOverlay' '121,0,0,0'
    $config = Set-IniValue $config 'Luma' 'SRUserType' '0'
    [IO.File]::WriteAllText($configPath, $config, [Text.UTF8Encoding]::new($false))
    Write-Host 'Installed and verified. Start normally; F10 opens the overlay.'
    Write-Host "Backup / uninstall record: $backup"
} catch {
    Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'If copying started, run Uninstall.cmd to undo the recorded files.'
    exit 1
}
