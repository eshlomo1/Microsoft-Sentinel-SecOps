##
## Creates VMs on Hyper-V host
##
param
(
    # Count for number of VMs
    [Parameter(Position=0,Mandatory)]
    [Int]$WebServerCount
)

# List of web servers
$WebServers = 1..$WebServerCount | % {"WebServer$_"}

Configuration WebVM
{
    # Hyper-V host == localhost
    Node "localhost"
    {
        # Install the HyperV role on client SKU
        OptionalFeature HyperV
        {
            Ensure              = "Present"
            Name                = "Microsoft-Hyper-V-All"            
        }
        <# For Server nodes, use built-in Windows Feature resource
        WindowsFeature HyperV
        {
            Ensure              = "Present"
            Name                = "Hyper-V"
        }
        #>
      
        # Create the virtual switch
        VMSwitch InternalSwitch
        {
            Ensure              = "Present"
            Name                = "Internal"
            Type                = "Internal"
            Requires            = "[OptionalFeature]HyperV"
        }

        # Check for Parent VHD file
        File VHDParentFile
        {
            Ensure              = "Present"
            DestinationPath     = "C:\Demo\VHD\Library\LibWeb.vhd"
            Type                = "File"
            Requires            = "[OptionalFeature]HyperV"
        }

        # Check the destination VHD folder
        File VHDFolder
        {
            Ensure              = "Present"
            DestinationPath     = "C:\Demo\VHD"
            Type                = "Directory"
            Requires            = "[File]VHDParentFile"
        }

        # For each of the VM Name, create VHD & VM
        foreach($name in $WebServers)
        {
            # Create VM specific VHD
            VHD "Vhd$Name"
            {
                Ensure          = "Present"
                Name            = $Name
                Path            = "C:\Demo\VHD"
                ParentPath      = "C:\Demo\VHD\Library\LibWeb.vhd"
                Requires        = @("[OptionalFeature]HyperV",
                                    "[File]VHDFolder")
            }

            # Create VM using the above VHD
            VM "VM$Name"
            {
                Ensure          = "Present"
                Name            = $Name
                VhDPath         = "C:\Demo\VHD\$Name"
                SwitchName      = "Internal"
                StartupMemoryMB = 1024
                State           = "Running"
                #WaitForIP       = $true
                Requires        = @("[OptionalFeature]HyperV",
                                    "[VMSwitch]InternalSwitch",
                                    "[VHD]Vhd$Name")
            }
        }

        # For each of the VM Name, wait for VMs to get IP
        foreach($name in $WebServers)
        {
            # Using the script, check for VM IP
            Script "WaitforIP$name"
            {
                GetScript  = "aaa"
                SetScript  = " while((Get-VM $Name | Select-Object -ExpandProperty NetworkAdapters).IPAddresses.count -lt 2) `
                              { `
                                Write-Verbose -Message `"Waiting for VM $Name to get IP Address`"
                                Start-Sleep -Seconds 3
                              }"
                TestScript = "((Get-VM $Name | Select-Object -ExpandProperty NetworkAdapters).IPAddresses).count -ge 2"
                Requires   = "[VM]VM$Name"
            }            
        }
    }

    # Rename all the WebVMs
    foreach($name in $WebServers)
    {
        Node $Name
        {
            # Rename the computers
            Computer "Rename$Name)"
            {
                Ensure = "Present"
                Name   = $Name
            }
        }
    }
}

# Create the MOF file for the specified configuration
WebVM

# Make it happen - Copy the MOF files to appropriate nodes and invoke the configuration
Start-DSCConfiguration -ComputerName localhost -Path $PSScriptRoot\WebVM -Wait -Verbose -Force
Start-DSCConfiguration -ComputerName $WebServers -Path $PSScriptRoot\WebVM -Wait -Verbose -Force

Sleep 1
# Restart the Webservers after machine rename
"Restarting the $WebServers"
Stop-VM -Name $WebServers -Force
Start-VM -Name $WebServers

# Wait for VM connectivity
$WebServers | % { Get-VMIPAddress -Name $psitem}