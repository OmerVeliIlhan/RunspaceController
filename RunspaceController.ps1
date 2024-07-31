# Runspace Havuzu Oluşturma
function New-RunspacePool {
    param (
        [int]$MinRunspaces = 1,
        [int]$MaxRunspaces = 5
    )

    $runspacePool = [runspacefactory]::CreateRunspacePool($MinRunspaces, $MaxRunspaces)
    $runspacePool.Open()
    return $runspacePool
}

# Runspace Oluşturma ve Başlatma
function Start-Runspace {
    param (
        [System.Management.Automation.Runspaces.RunspacePool]$RunspacePool,
        [scriptblock]$ScriptBlock
    )

    $runspace = [powershell]::Create().AddScript($ScriptBlock)
    $runspace.RunspacePool = $RunspacePool
    $runspace.BeginInvoke()
    return $runspace
}

# Runspace Sonuçlarını Alma
function Get-RunspaceResult {
    param (
        [System.Management.Automation.PowerShell]$Runspace
    )

    $runspace.EndInvoke($runspace.BeginInvoke())
    return $runspace.Streams
}
