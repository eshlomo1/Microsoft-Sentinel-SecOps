function Get-VMIPAddress
{
    param
    (
        [Parameter(Mandatory)]
        [string]$Name
    )

    $ErrorActionPreference = "SilentlyContinue"

    $vm = Get-WmiObject -Namespace root\virtualization\v2 -Class Msvm_ComputerSystem | ? ElementName -eq $Name
    $vm.GetRelated("Msvm_KvpExchangeComponent").GuestIntrinsicExchangeItems | % `
    {
        $GuestExchangeItemXml = ([XML]$_).SelectSingleNode("/INSTANCE/PROPERTY[@NAME='Name']/VALUE[child::text()='NetworkAddressIPv4']")
        if ($GuestExchangeItemXml) 
        { 
            $GuestExchangeItemXml.SelectSingleNode("/INSTANCE/PROPERTY[@NAME='Data']/VALUE/child::text()").Value 
        }    
    }
}