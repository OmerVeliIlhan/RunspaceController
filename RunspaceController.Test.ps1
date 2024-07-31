# RunspaceController.Tests.ps1

Import-Module 'C:\code\RunspaceController\RunspaceController.psm1'

Describe 'RunspaceController Module' {
    Context 'New-RunspacePool' {
        It 'Creates a runspace pool with specified min and max runspaces' {
            $runspacePool = New-RunspacePool -MinRunspaces 1 -MaxRunspaces 5
            $runspacePool | Should -Not -BeNullOrEmpty
            $runspacePool.GetType().FullName | Should -Be 'System.Management.Automation.Runspaces.RunspacePool'
        }
    }

    Context 'Start-Runspace' {
        It 'Starts a runspace and returns a PowerShell and AsyncResult' {
            $runspacePool = New-RunspacePool -MinRunspaces 1 -MaxRunspaces 5
            $scriptBlock = {
                param ($jobNumber)
                "Job $jobNumber"
            }
            $runspaceInfo = Start-Runspace -RunspacePool $runspacePool -ScriptBlock $scriptBlock -ArgumentList @(1)
            $runspaceInfo | Should -Not -BeNullOrEmpty
            $runspaceInfo.PowerShell | Should -Not -BeNullOrEmpty
            $runspaceInfo.AsyncResult | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Get-RunspaceResult' {
        It 'Retrieves the result of a runspace execution' {
            $runspacePool = New-RunspacePool -MinRunspaces 1 -MaxRunspaces 5
            $scriptBlock = {
                param ($jobNumber)
                "Job $jobNumber"
            }
            $runspaceInfo = Start-Runspace -RunspacePool $runspacePool -ScriptBlock $scriptBlock -ArgumentList @(1)
            $result = Get-RunspaceResult -Runspace $runspaceInfo
            $result | Should -Be 'Job 1'
        }
    }

    Context 'Close-RunspacePool' {
        It 'Closes and disposes of the runspace pool' {
            $runspacePool = New-RunspacePool -MinRunspaces 1 -MaxRunspaces 5
            Close-RunspacePool -RunspacePool $runspacePool
            { $runspacePool.Dispose() } | Should -Throw 'Cannot access a closed pool.'
        }
    }

    Context 'Integration Test' {
        It 'Executes multiple jobs in parallel and collects results' {
            $runspacePool = New-RunspacePool -MinRunspaces 1 -MaxRunspaces 10
            $scriptBlock = {
                param ($jobNumber)
                Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 3)
                $threadId = [System.Threading.Thread]::CurrentThread.ManagedThreadId
                "Job $jobNumber completed by thread $threadId"
            }

            $runspaces = @()
            for ($i = 1; $i -le 20; $i++) {
                $runspaceInfo = Start-Runspace -RunspacePool $runspacePool -ScriptBlock $scriptBlock -ArgumentList @($i)
                $runspaces += $runspaceInfo
            }

            $results = @()
            foreach ($runspaceInfo in $runspaces) {
                $results += Get-RunspaceResult -Runspace $runspaceInfo
            }

            Close-RunspacePool -RunspacePool $runspacePool

            $results.Count | Should -Be 20
            $results | ForEach-Object { $_ | Should -Match 'Job \d+ completed by thread \d+' }
        }
    }
}
