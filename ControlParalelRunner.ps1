Import-Module "C:\code\PSParallelProcessing\ParallelTaskRunner.ps1" -Force

# Global variable to hold the ParallelTaskRunner instance
$global:ParallelExecutor = $null

function Start-ParallelExecutor {
    param (
        [int]$CpuUsage
    )
    $global:ParallelExecutor = [ParallelTaskRunner]::new($CpuUsage)
}

function Set-ParallelCpu {
    param (
        [int]$CpuUsage
    )
    if ($null -ne $global:ParallelExecutor) {
        $global:ParallelExecutor.SetCpuUsage($CpuUsage)
    } else {
        Write-Host "ParallelExecutor is not running. Use Start-ParallelExecutor to initialize."
    }
}

function Add-ParallelTasks {
    param (
        [object[]]$Tasks,
        [ScriptBlock]$ScriptBlock
    )
    if ($null -ne $global:ParallelExecutor) {
        $global:ParallelExecutor.AddTasks($Tasks, $ScriptBlock)
    } else {
        Write-Host "ParallelExecutor is not running. Use Start-ParallelExecutor to initialize."
    }
}

function Execute-ParallelTasks {
    if ($null -ne $global:ParallelExecutor) {
        return $global:ParallelExecutor.ExecuteTasks()
    } else {
        Write-Host "ParallelExecutor is not running. Use Start-ParallelExecutor to initialize."
    }
}