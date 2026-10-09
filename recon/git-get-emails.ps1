<#
.SYNOPSIS
    List the unique author names and emails from a Git repository's log.

.DESCRIPTION
    Windows/PowerShell port of recon/git-get-emails.fish.
    Equivalent to: git log --format='%an <%ae>' | sort | uniq [git args]

    Any extra arguments are passed through to git log
    (for example --all, a branch name, or a path).

.EXAMPLE
    .\git-get-emails.ps1

.EXAMPLE
    .\git-get-emails.ps1 --all
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]] $GitArgs
)

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Required tool 'git' was not found on PATH." -ForegroundColor Red
    exit 1
}

git log "--format=%an <%ae>" @GitArgs | Sort-Object -Unique
exit $LASTEXITCODE
