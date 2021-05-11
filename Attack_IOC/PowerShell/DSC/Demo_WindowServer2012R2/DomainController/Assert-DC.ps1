##
## Installs ADDS, DHCP and does DCPromo
##
Configuration DomainController
{
    Node "192.168.10.1"
    {  
        Computer RenameDC
        {
            Ensure   = "Present"
            Name     = "Dc"
        }
                
        WindowsFeature DC
        {
            Ensure   = "Present"
            Name     = "AD-Domain-Services"
            Requires = "[Computer]RenameDC"
        }

        DCPromo Promote
        {
            Ensure                        = "Present"
            DomainName                    = "fourthcoffee.com"
            SafeModeAdministratorPassword = (Import-Clixml "C:\Demo\Setup\DomainCred.clixml")
            Requires                      = "[WindowsFeature]DC"
        }

        WindowsFeature DHCP
        {
            Ensure   = "Present"
            Name     = "DHCP"
            Requires = "[DCPromo]Promote"
        }

        DHCPScope PowerShellScope
        {
            Ensure            = "Present"
            Name              = "PowerShell"
            ID                = "192.168.10.0"
            StartRange        = "192.168.10.3"
            EndRange          = "192.168.10.254"
            SubnetMask        = "255.255.255.0"
            LeaseDurationDays = 1
            Type              = "Dhcp"
            State             = "Active"
            Requires          = "[WindowsFeature]DHCP"
        }
        
        DHCPOption FourthCoffeeOption
        {
            Ensure        = "Present"
            DNSServerName = "192.168.10.1"
            DomainName    = "fourthcoffee.com"
            Router        = "192.168.10.1"
            Requires      = "[DHCPScope]PowerShellScope"
        }
        
        DHCPServerinDC DhcpInDC
        {
            Ensure    ="Present"
            DNSName   = "dc.fourthcoffee.com"
            IPAddress = "192.168.10.1"
            Requires  = "[DHCPOption]FourthCoffeeOption"
        }
    }
}

# Create the MOF file for the configuration
DomainController

# Make it happen
Start-DSCConfiguration -Path $PSScriptRoot\DomainController -Wait -Verbose -Force

# Need restart after machine rename
Write-Verbose -Message "Restarting 192.168.10.1 after rename ...."
Restart-Computer -Protocol WSMan -ComputerName 192.168.10.1 -Wait -For WinRM -Force
Write-Verbose -Message "Restarting completed"

# Make it happen. Restart will happen after DC Promo
Start-DscConfiguration -Path $PSScriptRoot\DomainController -Wait -Verbose -Force

# Wait for VM connectivity
while( ! (Get-VMIPAddress DC))
{
    Write-Verbose -Message "Waiting for VM to get IP Address"
    Start-Sleep -Seconds 3
}

# Make it happen. Install DHCP and its options
Start-DscConfiguration -Path $PSScriptRoot\DomainController -Wait -Verbose -Force