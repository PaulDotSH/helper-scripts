<#
.SYNOPSIS
    Optimize every PDF in a folder with qpdf (parallel), producing <name>-optimized.pdf.

.DESCRIPTION
    Windows/PowerShell port of drive/optimize-pdf.sh.

.EXAMPLE
    .\optimize-pdf.ps1 C:\path\to\folder
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Path,

    [int] $Throttle = [math]::Max(1, [Environment]::ProcessorCount)
)

. "$PSScriptRoot\_Common.ps1"

if (-not $Path) {
    Write-Host "Usage: $($MyInvocation.MyCommand.Name) <path>"
    exit 1
}

if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    Write-Host "Error: The provided path '$Path' is not a valid directory."
    exit 1
}

try {
    Assert-Tool -Name 'qpdf' -Hint 'Install it with: winget install --id QPDF.QPDF -e'
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$root = (Resolve-Path -LiteralPath $Path).ProviderPath
$pdfs = @(Get-ChildItem -LiteralPath $root -File | Where-Object { $_.Extension -ieq '.pdf' })

if ($pdfs.Count -eq 0) {
    Write-Host "No PDF files found in '$root'."
    return
}

Invoke-Parallel -InputObject $pdfs -Throttle $Throttle -ScriptBlock {
    param($pdf)

    $output = Join-Path $pdf.DirectoryName ("{0}-optimized.pdf" -f $pdf.BaseName)
    & qpdf --optimize-images --linearize $pdf.FullName -- $output

    if ($LASTEXITCODE -ne 0) {
        throw "qpdf failed for '$($pdf.Name)' (exit code $LASTEXITCODE)."
    }

    "Optimized '$($pdf.Name)' -> '$([IO.Path]::GetFileName($output))'."
}
