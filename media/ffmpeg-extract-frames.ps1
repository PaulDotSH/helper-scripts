<#
.SYNOPSIS
    Extract frames from a video as sequentially numbered PNG files using ffmpeg.

.DESCRIPTION
    Windows/PowerShell port of media/ffmpeg-extract-frames.fish.
    Equivalent to: ffmpeg '%04d.png' -i <input...>

    Frames are written to the current directory as 0001.png, 0002.png, ... .
    Any extra arguments are appended after -i and passed through to ffmpeg.

.EXAMPLE
    .\ffmpeg-extract-frames.ps1 .\clip.mp4
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments = $true)]
    [string[]] $InputPath
)

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Required tool 'ffmpeg' was not found on PATH." -ForegroundColor Red
    exit 1
}

& ffmpeg '%04d.png' -i @InputPath
exit $LASTEXITCODE
