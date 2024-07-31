Import-Module 'C:\code\RunspaceController\RunspaceController.psm1'

Get-Command -Module RunspaceController

$runspacePool = New-RunspacePool -MinRunspaces 1 -MaxRunspaces 5

$scriptBlock = {
    Start-Sleep -Seconds 2
    "Runspace executed!"
}

$runspaceInfo = Start-Runspace -RunspacePool $runspacePool -ScriptBlock $scriptBlock
$results = Get-RunspaceResult -Runspace $runspaceInfo
$results

Close-RunspacePool -RunspacePool $runspacePool
