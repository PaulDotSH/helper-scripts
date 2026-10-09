<#
.SYNOPSIS
    Download the audio track of a video as M4A using yt-dlp.

.DESCRIPTION
    Windows/PowerShell port of media/yt-dlp-m4a.fish.
    Equivalent to: yt-dlp -x --audio-format m4a --audio-quality 0 <url...>

.EXAMPLE
    .\yt-dlp-m4a.ps1 https://www.youtube.com/watch?v=dQw4w9WgXcQ
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments = $true)]
    [string[]] $Url
)

if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Required tool 'yt-dlp' was not found on PATH." -ForegroundColor Red
    exit 1
}

& yt-dlp -x --audio-format m4a --audio-quality 0 @Url
exit $LASTEXITCODE
