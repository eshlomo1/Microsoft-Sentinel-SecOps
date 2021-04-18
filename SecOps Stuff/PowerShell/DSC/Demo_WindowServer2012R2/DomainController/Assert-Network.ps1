##
## Sets the networking between DC VM and Hyper-V Host
##
Configuration Network
{
    # Find the DCVM ipaddress dynamically, 
    # since we don't know the VM IPAddress a priori.
    Node (Get-VMIPAddress DC) 
    {
        $Node = Get-VMIPAddress DC
        IPAddress DCNetwork
        {
            Ensure         = "Present"
            IPAddress      = "192.168.10.1"
            InterfaceAlias = "*Ethernet*"
            PrefixLength   = 24
            DefaultGateway = "192.168.10.1"
        }
    }

    Node "Localhost"
    {
        IPAddress LocalNetwork
        {
            Ensure         = "Present"
            IPAddress      = "192.168.10.2"
            InterfaceAlias = "*vEthernet*"
            PrefixLength   = 24
            DefaultGateway = "192.168.10.1"
        }
    }
}

# Create the MOF file for the configuration
Network

# Make it happen for DC first and then localhost
$dcIP = Get-VMIPAddress DC
Start-DSCConfiguration -Path $PSScriptRoot\Network -Wait -Verbose -ComputerName $dcIP
Start-DSCConfiguration -Path $PSScriptRoot\Network -Wait -Verbose -ComputerName localhost