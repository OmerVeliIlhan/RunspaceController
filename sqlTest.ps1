# Import the RunspaceController module and SQL Server module
Import-Module 'C:\code\RunspaceController\RunspaceController.psm1'

# Define the connection string

# Function to execute a query
function Execute-Query {
    param (
        [string]$query
    )
    Invoke-Sqlcmd -Query $query -ServerInstance "DESKTOP-HM0DI2V\SQLEXPRESS" -Database "TestDB" -ErrorAction Stop -ConnectionTimeout 5 -TrustServerCertificate
}

# Function to process a single operation
$processOperationScriptBlock = {
    param ($connectionString, $operationID)
    try {
        $query = "SELECT Operand1, Operand2, Operation FROM MathOperations WHERE OperationID = $operationID;"
        $operation = Invoke-Sqlcmd -Query $query -ServerInstance "DESKTOP-HM0DI2V\SQLEXPRESS" -Database "TestDB" -ErrorAction Stop -ConnectionTimeout 5 -TrustServerCertificate | Select-Object -First 1

        if ($operation.Operation -eq '+') {
            $result = $operation.Operand1 + $operation.Operand2
        } elseif ($operation.Operation -eq '-') {
            $result = $operation.Operand1 - $operation.Operand2
        } elseif ($operation.Operation -eq '*') {
            $result = $operation.Operand1 * $operation.Operand2
        } elseif ($operation.Operation -eq '/') {
            if ($operation.Operand2 -eq 0) {
                throw "Division by zero"
            }
            $result = $operation.Operand1 / $operation.Operand2
        }

        $updateQuery = "UPDATE MathOperations SET Result = $result, Status = 'Succeeded' WHERE OperationID = $operationID;"
        Invoke-Sqlcmd -Query $updateQuery -ServerInstance "DESKTOP-HM0DI2V\SQLEXPRESS" -Database "TestDB" -ErrorAction Stop -ConnectionTimeout 5 -TrustServerCertificate
    } catch {
        $updateQuery = "UPDATE MathOperations SET Status = 'Failed' WHERE OperationID = $operationID;"
        Invoke-Sqlcmd -Query $updateQuery -ServerInstance "DESKTOP-HM0DI2V\SQLEXPRESS" -Database "TestDB" -ErrorAction Stop -ConnectionTimeout 5 -TrustServerCertificate
    }
}

# Create the runspace pool
$runspacePool = New-RunspacePool -MinRunspaces 1 -MaxRunspaces 10

# Select all rows with status 'Not Started'
$selectQuery = "SELECT OperationID FROM MathOperations WHERE Status = 'Not Started';"
$operations = Execute-Query -query $selectQuery

# Start runspaces for each operation
$runspaces = @()
foreach ($operation in $operations) {
    $runspaceInfo = Start-Runspace -RunspacePool $runspacePool -ScriptBlock $processOperationScriptBlock -ArgumentList $connectionString, $operation.OperationID
    $runspaces += $runspaceInfo
}

# Collect results
foreach ($runspaceInfo in $runspaces) {
    Get-RunspaceResult -Runspace $runspaceInfo
}

# Close the runspace pool
Close-RunspacePool -RunspacePool $runspacePool

Write-Output "Processing complete. Check the MathOperations table for status updates."
