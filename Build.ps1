$ErrorActionPreference = 'Stop'
$artifacts = Join-Path $PSScriptRoot 'artifacts'
$files = @('Install.cmd', 'Uninstall.cmd', 'Setup.ps1', 'README.txt', 'LICENSE')
$paths = @($files | ForEach-Object { Join-Path $PSScriptRoot $_ })
foreach ($path in $paths) {
    if (!(Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing release file: $path" }
}
New-Item -ItemType Directory -Path $artifacts -Force | Out-Null
$archive = Join-Path $artifacts 'Watch-Dogs-2-Flicker-Fix-Setup.zip'
Compress-Archive -LiteralPath $paths -DestinationPath $archive -Force
$hash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText((Join-Path $artifacts 'SHA256SUMS.txt'), "$hash  Watch-Dogs-2-Flicker-Fix-Setup.zip
", [Text.UTF8Encoding]::new($false))
Write-Host "Built: $archive"
Write-Host "SHA-256: $hash"
