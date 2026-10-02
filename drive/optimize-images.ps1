<#
.SYNOPSIS
    Optimize images in a folder: convert HEIC/BMP/TIFF/GIF to PNG, then PNG/JPG/JPEG to WebP (parallel).

.DESCRIPTION
    Windows/PowerShell port of drive/optimize-images.sh.
    Uses ImageMagick (magick) instead of GraphicsMagick (gm) and libwebp (cwebp).

.EXAMPLE
    .\optimize-images.ps1 C:\path\to\folder
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
    Assert-Tool -Name 'magick', 'cwebp' -Hint 'Install with: winget install --id ImageMagick.ImageMagick -e and winget install --id Google.Libwebp -e'
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$root = (Resolve-Path -LiteralPath $Path).ProviderPath
$pngSources = @('.heic', '.bmp', '.tiff', '.gif')
$webpSources = @('.png', '.jpg', '.jpeg')

$toConvert = @(Get-ChildItem -LiteralPath $root -File |
    Where-Object { $pngSources -contains $_.Extension.ToLowerInvariant() })

if ($toConvert.Count -gt 0) {
    Invoke-Parallel -InputObject $toConvert -Throttle $Throttle -ScriptBlock {
        param($image)

        $output = [IO.Path]::ChangeExtension($image.FullName, '.png')
        & magick $image.FullName -quality 100 -compress Zip $output
        if ($LASTEXITCODE -ne 0) {
            throw "magick failed for '$($image.Name)' (exit code $LASTEXITCODE)."
        }

        "Converted '$($image.Name)' -> '$([IO.Path]::GetFileName($output))'."
    }
}

$toWebp = @(Get-ChildItem -LiteralPath $root -File |
    Where-Object { $webpSources -contains $_.Extension.ToLowerInvariant() })

if ($toWebp.Count -gt 0) {
    Invoke-Parallel -InputObject $toWebp -Throttle $Throttle -ScriptBlock {
        param($image)

        $output = [IO.Path]::ChangeExtension($image.FullName, '.webp')
        & cwebp -quiet -q 90 $image.FullName -o $output
        if ($LASTEXITCODE -ne 0) {
            throw "cwebp failed for '$($image.Name)' (exit code $LASTEXITCODE)."
        }

        "Converted '$($image.Name)' -> '$([IO.Path]::GetFileName($output))'."
    }
}

if ($toConvert.Count -eq 0 -and $toWebp.Count -eq 0) {
    Write-Host "No matching image files found in '$root'."
}
