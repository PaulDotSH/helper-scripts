# Shared helpers for the Windows (PowerShell) variants of the drive scripts.

function Assert-Tool {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string[]] $Name,
        [string] $Hint
    )

    foreach ($n in $Name) {
        if (-not (Get-Command $n -ErrorAction SilentlyContinue)) {
            throw "Required tool '$n' was not found on PATH. $Hint"
        }
    }
}

function Invoke-Parallel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [object[]] $InputObject,

        [Parameter(Mandatory, Position = 1)]
        [scriptblock] $ScriptBlock,

        [int] $Throttle = [math]::Max(1, [Environment]::ProcessorCount)
    )

    if ($InputObject.Count -eq 0) { return }

    $pool = [runspacefactory]::CreateRunspacePool(1, $Throttle)
    $pool.Open()
    $jobs = [System.Collections.Generic.List[object]]::new()
    try {
        foreach ($item in $InputObject) {
            $ps = [powershell]::Create()
            $ps.RunspacePool = $pool
            [void] $ps.AddScript($ScriptBlock).AddArgument($item)
            $jobs.Add([pscustomobject]@{ PowerShell = $ps; Handle = $ps.BeginInvoke() })
        }

        foreach ($job in $jobs) {
            try {
                $job.PowerShell.EndInvoke($job.Handle) | ForEach-Object { Write-Host $_ }
                foreach ($err in $job.PowerShell.Streams.Error) {
                    Write-Host $err -ForegroundColor Red
                }
            }
            finally {
                $job.PowerShell.Dispose()
            }
        }
    }
    finally {
        $pool.Close()
        $pool.Dispose()
    }
}
