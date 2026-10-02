<#
.SYNOPSIS
    Recursively list build/leftover artifacts (.dll, .o, .exe, .pkg, .tmp, .wav).

.DESCRIPTION
    Windows/PowerShell port of drive/find-files.sh.

.EXAMPLE
    .\find-files.ps1 C:\path\to\folder
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Path
)

if (-not $Path) {
    Write-Host "Usage: $($MyInvocation.MyCommand.Name) <path>"
    exit 1
}

if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    Write-Host "Error: The provided path '$Path' is not a valid directory."
    exit 1
}

$extensions = @('.dll', '.o', '.exe', '.pkg', '.tmp', '.wav')
$root = (Resolve-Path -LiteralPath $Path).ProviderPath

Get-ChildItem -LiteralPath $root -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object { $extensions -contains $_.Extension.ToLowerInvariant() } |
    ForEach-Object {
        $relative = $_.FullName.Substring($root.Length).TrimStart('\')
        "./$($relative -replace '\\', '/')"
    }
