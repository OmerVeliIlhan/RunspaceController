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

# Create and Start Runspace
function Start-Runspace {
    param (
        [System.Management.Automation.Runspaces.RunspacePool]$RunspacePool,
        [scriptblock]$ScriptBlock
    )

    $powershell = [powershell]::Create().AddScript($ScriptBlock)
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

    $result = $PowerShell.EndInvoke($AsyncResult)
    $PowerShell.Dispose()
    return $result
}

# Close Runspace Pool
function Close-RunspacePool {
    param (
        [System.Management.Automation.Runspaces.RunspacePool]$RunspacePool
    )

    $RunspacePool.Close()
    $RunspacePool.Dispose()
}
