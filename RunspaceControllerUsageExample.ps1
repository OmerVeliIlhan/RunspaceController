Import-Module 'C:\code\RunspaceController\RunspaceController.psm1'

$runspacePool = New-RunspacePool -MinRunspaces 1 -MaxRunspaces 5
$scriptBlock = {
    Start-Sleep -Seconds 2
    "Runspace çalıştı!"
}
$runspace = Start-Runspace -RunspacePool $runspacePool -ScriptBlock $scriptBlock
$results = Get-RunspaceResult -Runspace $runspace
$results

# Runspace havuzunu kapatma
Close-RunspacePool -RunspacePool $runspacePool
