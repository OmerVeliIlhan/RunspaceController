﻿# UsageExample.ps1

# Import the ControlFunctions script
import-module "C:\code\PSParallelProcessing\ControlParalelRunner.ps1"

# Initialize the ParallelExecutor with 50% CPU usage
Start-ParallelExecutor -CpuUsage 50

# Define the tasks and the script block
$tasks = 1..10
$scriptBlock = {
    param ($task)
    Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 3)
    "Task $task completed"
}

# Add tasks to the ParallelExecutor
Add-ParallelTasks -Tasks $tasks -ScriptBlock $scriptBlock

# Execute tasks and get results
$results = Execute-ParallelTasks
$results | ForEach-Object { $_ }

# Adjust CPU usage to 30%
Set-ParallelCpu -CpuUsage 30
