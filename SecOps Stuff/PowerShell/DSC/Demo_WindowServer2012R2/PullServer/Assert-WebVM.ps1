##
## Creates VMs on Hyper-V host and configures the VM for pull mode
##
param
(
    # Configuration File that defines the environmental data
    [Parameter(Position=0,Mandatory)]
    [Int]$WebServerCount
)

# List of web servers
$WebServers = 1..$WebServerCount | % {"WebServer$_"}
$GuidCollection = @{WebServer1 = '8cac052d-d3d4-423e-b088-f93979094d11'
                    WebServer2 = 'e349d5e6-337b-48e6-b381-6dcc4d707750'}

Configuration WebVM
{
    # Hyper-V host == localhost
    Node "localhost"
    {
        # Install the HyperV role on client SKU
        OptionalFeature HyperV
        {
            Ensure          = "Present"
            Name            = "Microsoft-Hyper-V-All"            
        }
      
        # Create the virtual switch
        VMSwitch InternalSwitch
        {
            Ensure          = "Present"
            Name            = "Internal"
            Type            = "Internal"
            Requires        = "[OptionalFeature]HyperV"
        }

        # Check for Parent VHD file
        File VHDParentFile
        {
            Ensure          = "Present"
            DestinationPath = "C:\Demo\VHD\Library\LibWindows.vhd"
            Type            = "File"
            Requires        = "[OptionalFeature]HyperV"
        }

        # Check the destination VHD folder
        File VHDFolder
        {
            Ensure          = "Present"
            DestinationPath = "C:\Demo\VHD"
            Type            = "Directory"
            Requires        = "[File]VHDParentFile"
        }

        # For each of the VM Name, create VHD & VM
        foreach($name in $WebServers)
        {
            # Create VM specific VHD
            VHD "Vhd$Name"
            {
                Ensure     = "Present"
                Name       = $Name
                Path       = "C:\Demo\VHD"
                ParentPath = "C:\Demo\VHD\Library\LibWindows.vhd"
                Requires   = @("[OptionalFeature]HyperV",
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
                GetScript = "aaa"
                SetScript = " while((Get-VM $Name | Select-Object -ExpandProperty NetworkAdapters).IPAddresses.count -lt 2) `
                              { `
                                Write-Verbose -Message `"Waiting for VM $Name to get IP Address`"
                                Start-Sleep -Seconds 3
                              }"
                TestScript = "((Get-VM $Name | Select-Object -ExpandProperty NetworkAdapters).IPAddresses).count -ge 2"
                Requires = "[VM]VM$Name"
            }            
        }
    }

    # For each VM, set it to Pull mode and related meta-data
    foreach($name in $WebServers)
    {         
        Node $Name
        {
            # Set the DSC engine (LCM) to Pull mode
            DesiredStateConfigurationSettings LCM
            {
                ConfigurationID           = $GuidCollection["$Name"]
                ConfigurationMode         = "Pull"
                DownloadManagerName       = "WebDownloadManager"
                DownloadManagerCustomData = @{ServerUrl = "http://PullServer:8080/PSDSCPullServer/PSDSCPullServer.svc"}
                PullActionRefreshFrequencyInSeconds =  60
            }
        }
    }
}

# Create the MOF file for the configuration
WebVM

# Make it happen on Hyper-V host - Copy the MOF files to appropriate nodes and invoke the configuration
Start-DSCConfiguration -ComputerName localhost -Path $PSScriptRoot\WebVM -Wait -Verbose

# Make it happen - Set the WebServers to Pull mode
Set-DSCLocalConfigurationManager -ComputerName $WebServers -Path $PSScriptRoot\WebVM -Verbose