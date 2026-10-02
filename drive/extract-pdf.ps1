<#
.SYNOPSIS
    Extract each PDF in a folder to images (HTML + PNG via pdftohtml, then PNG/JPG to WebP).

.DESCRIPTION
    Windows/PowerShell port of drive/extract-pdf.sh.
    Produces one sub-folder per PDF containing WebP images converted from the rendered pages.

.EXAMPLE
    .\extract-pdf.ps1 C:\path\to\folder
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
    Assert-Tool -Name 'pdftohtml', 'cwebp' -Hint 'Install pdftohtml (poppler/MiKTeX) and libwebp: winget install --id Google.Libwebp -e'
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

$workItems = $pdfs | ForEach-Object { [pscustomobject]@{ Folder = $root; Pdf = $_ } }

Invoke-Parallel -InputObject $workItems -Throttle $Throttle -ScriptBlock {
    param($item)

    $pdf = $item.Pdf
    $outputFolder = Join-Path $item.Folder $pdf.BaseName
    New-Item -ItemType Directory -Force -Path $outputFolder | Out-Null

    $htmlOutput = Join-Path $outputFolder ($pdf.BaseName + '.html')
    & pdftohtml -c -hidden $pdf.FullName $htmlOutput
    if ($LASTEXITCODE -ne 0) {
        throw "pdftohtml failed for '$($pdf.Name)' (exit code $LASTEXITCODE)."
    }

    $images = @(Get-ChildItem -LiteralPath $outputFolder -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -match '(?i)^\.(png|jpe?g)$' })

    foreach ($image in $images) {
        $webp = [IO.Path]::ChangeExtension($image.FullName, '.webp')
        & cwebp -quiet -q 90 $image.FullName -o $webp
        if ($LASTEXITCODE -ne 0) {
            throw "cwebp failed for '$($image.Name)' (exit code $LASTEXITCODE)."
        }
    }

    Get-ChildItem -LiteralPath $outputFolder -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -ieq '.html' -or $_.Extension -ieq '.png' } |
        Remove-Item -Force -ErrorAction SilentlyContinue

    "Finished processing '$($pdf.BaseName)'. Converted images are in '$outputFolder'."
}
