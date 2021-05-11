param
(
    [Parameter(Mandatory)]
    [String[]]$ComputerName,

    [ValidateRange(1,3)]
    [uint32]$flag = 3
)

Invoke-CimMethod -ComputerName $ComputerName -Namespace root/microsoft/windows/desiredstateconfiguration `
                 -Class MSFT_DscLocalConfigurationManager -MethodName ConsistencyCheck `
                 -Arguments @{Flags=[uint32]$flag} -Verbose