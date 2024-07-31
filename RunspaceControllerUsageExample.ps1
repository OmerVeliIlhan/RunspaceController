Import-Module 'C:\code\RunspaceController\RunspaceController.psm1'

# Create Runspace Pool
$runspacePool = New-RunspacePool -MinRunspaces 1 -MaxRunspaces 10

# Script block to execute
$scriptBlock = {
    param ($jobNumber)
    Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5)
    $threadId = [System.Threading.Thread]::CurrentThread.ManagedThreadId
    "Job $jobNumber completed by thread $threadId"
}

# Start multiple runspaces
$runspaces = @()
for ($i = 1; $i -le 20; $i++) {
    $runspaceInfo = Start-Runspace -RunspacePool $runspacePool -ScriptBlock $scriptBlock -ArgumentList @($i)
    $runspaces += $runspaceInfo
}

# Collect results
$results = @()
foreach ($runspaceInfo in $runspaces) {
    $results += Get-RunspaceResult -Runspace $runspaceInfo
}

# Close runspace pool
Close-RunspacePool -RunspacePool $runspacePool

# Output results
$results | ForEach-Object { Write-Output $_ }
