@{
    # Script module or binary module file associated with this manifest
    RootModule = 'RunspaceController.psm1'

    # Version number of this module.
    ModuleVersion = '0.1.1'

    # ID used to uniquely identify this module
    GUID = '8bc19938-7b3e-4aa1-a2d0-0eedbabab5c2'

    # Author of this module
    Author = 'Ömer Veli İlhan'

    # Company or vendor of this module
    CompanyName = ''

    # Description of the functionality provided by this module
    Description = 'PowerShell module to simplify runspace management.'

    # Functions to export from this module
    FunctionsToExport = @(
        'New-RunspacePool',
        'Start-Runspace',
        'Get-RunspaceResult',
        'Close-RunspacePool'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()
}