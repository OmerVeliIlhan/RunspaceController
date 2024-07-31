# Create Runspace Pool
function New-RunspacePool {
    param (
        [int]$MinRunspaces = 1,
        [int]$MaxRunspaces = 5
    )

    $runspacePool = [runspacefactory]::CreateRunspacePool($MinRunspaces, $MaxRunspaces)
    $runspacePool.Open()
    return $runspacePool
}

# Set Min and Max Runspace Counts by recreating the pool
function Set-RunspacePoolLimits {
    param (
        [System.Management.Automation.Runspaces.RunspacePool]$RunspacePool,
        [int]$MinRunspaces,
        [int]$MaxRunspaces
    )

    if ($RunspacePool.RunspacePoolStateInfo.State -ne 'Opened') {
        throw "Runspace pool must be in an Opened state to change limits."
    }

    # Close and dispose of the old runspace pool
    $RunspacePool.Close()
    $RunspacePool.Dispose()

    # Create and open a new runspace pool
    $newRunspacePool = [runspacefactory]::CreateRunspacePool($MinRunspaces, $MaxRunspaces)
    $newRunspacePool.Open()
    return $newRunspacePool
}

# Create and Start Runspace
function Start-Runspace {
    param (
        [System.Management.Automation.Runspaces.RunspacePool]$RunspacePool,
        [scriptblock]$ScriptBlock,
        [object[]]$ArgumentList
    )

    $powershell = [powershell]::Create().AddScript($ScriptBlock)
    foreach ($arg in $ArgumentList) {
        $powershell.AddArgument($arg) | Out-Null
    }
    $powershell.RunspacePool = $RunspacePool
    $asyncResult = $powershell.BeginInvoke()
    return @{ PowerShell = $powershell; AsyncResult = $asyncResult }
}

# Get Runspace Results
function Get-RunspaceResult {
    param (
        [System.Collections.Hashtable]$RunspaceInfo
    )

    $PowerShell = $RunspaceInfo.PowerShell
    $AsyncResult = $RunspaceInfo.AsyncResult

    if ($PowerShell -and $AsyncResult) {
        $result = $PowerShell.EndInvoke($AsyncResult)
        $PowerShell.Dispose()
        return $result
    } else {
        return "Error: Runspace did not execute properly."
    }
}

# Close Runspace Pool
function Close-RunspacePool {
    param (
        [System.Management.Automation.Runspaces.RunspacePool]$RunspacePool
    )

    $RunspacePool.Close()
    $RunspacePool.Dispose()
}
