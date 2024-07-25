using namespace System.Management.Automation
using namespace System.Management.Automation.Runspaces
using namespace System.Diagnostics

class ParallelTaskRunner {
    [RunspacePool]$RunspacePool
    [System.Collections.ArrayList]$Runspaces = @()
    [System.Collections.ArrayList]$Tasks = @()
    [System.Collections.ArrayList]$Results = @()
    [int]$MaxCpuUsage
    [int]$MaxThreads
    [int]$CurrentThreads = 0

    ParallelTaskRunner([int]$cpuUsagePercentage) {
        $this.SetCpuUsage($cpuUsagePercentage)
    }

    [void]SetCpuUsage([int]$cpuUsagePercentage) {
        $this.MaxCpuUsage = $cpuUsagePercentage
        $cpuCores = [Environment]::ProcessorCount
        $this.MaxThreads = [math]::Ceiling($cpuCores * ($cpuUsagePercentage / 100))
        if ($null -ne $this.RunspacePool) {
            $this.RunspacePool.Close()
            $this.RunspacePool.Dispose()
        }
        $this.RunspacePool = [runspacefactory]::CreateRunspacePool(1, $this.MaxThreads)
        $this.RunspacePool.Open()
    }

    [void]AddTasks([object[]]$tasks, [ScriptBlock]$scriptBlock) {
        foreach ($task in $tasks) {
            $this.Tasks.Add([PSCustomObject]@{ ScriptBlock = $scriptBlock; Argument = $task })
        }
    }

    [void]AdjustThreads() {
        $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples[0].CookedValue
        if ($cpuUsage -lt $this.MaxCpuUsage -and $this.CurrentThreads -lt $this.MaxThreads) {
            $this.CurrentThreads++
            $task = $this.Tasks[0]
            $this.Tasks.RemoveAt(0)
            $runspace = [powershell]::Create().AddScript($task.ScriptBlock).AddArgument($task.Argument)
            $runspace.RunspacePool = $this.RunspacePool
            $this.Runspaces.Add([PSCustomObject]@{ Pipeline = $runspace; Status = $runspace.BeginInvoke() })
        }
    }

    [object[]]ExecuteTasks() {
        while ($this.Tasks.Count -gt 0 -or $this.CurrentThreads -gt 0) {
            $this.AdjustThreads()
            # Create a copy of the Runspaces collection
            $runspacesCopy = @($this.Runspaces)
            foreach ($runspace in $runspacesCopy) {
                if ($runspace.Pipeline.EndInvoke($runspace.Status)) {
                    $this.Results += $runspace.Pipeline.Streams.Output
                    $runspace.Pipeline.Dispose()
                    $this.Runspaces.Remove($runspace)
                    $this.CurrentThreads--
                }
            }
            Start-Sleep -Milliseconds 500
        }
        $this.RunspacePool.Close()
        $this.RunspacePool.Dispose()
        return $this.Results
    }
}
