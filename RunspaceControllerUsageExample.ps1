# Runspace Havuzu Oluşturma
$runspacePool = New-RunspacePool -MinRunspaces 1 -MaxRunspaces 5

# Runspace Başlatma
$scriptBlock = {
    Start-Sleep -Seconds 2
    "Runspace çalıştı!"
}
$runspace = Start-Runspace -RunspacePool $runspacePool -ScriptBlock $scriptBlock

# Sonuçları Alma
$results = Get-RunspaceResult -Runspace $runspace
$results
