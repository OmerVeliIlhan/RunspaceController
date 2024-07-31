# Create and open a runspace pool
$runspacePool = [runspacefactory]::CreateRunspacePool(1, 5)
$runspacePool.Open()

# Define the script block
$scriptBlock = {
    param($task)
    Write-Output "Task $task started"
    Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 3)
    Write-Output "Task $task completed"
}

# Add tasks
$runspaces = @()
foreach ($task in 1..10) {
    $psInstance = [powershell]::Create().AddScript($scriptBlock).AddArgument($task)
    $psInstance.RunspacePool = $runspacePool
    $runspaces += [PSCustomObject]@{ Pipeline = $psInstance; Status = $psInstance.BeginInvoke() }
}

# Collect results
$results = @()
foreach ($runspace in $runspaces) {
    $results += $runspace.Pipeline.EndInvoke($runspace.Status)
    $runspace.Pipeline.Dispose()
}

# Close the pool
$runspacePool.Close()
$runspacePool.Dispose()

$results
