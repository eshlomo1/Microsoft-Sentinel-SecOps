Configuration PullServerVM
{
    $NodeName = "Localhost"
    $SwitchName = "Internal"
    $SwitchType = "Internal"
    $VMName = "PullServer"
    $VHDParentPath = "C:\Demo\VHD\Library\LibPull.vhd"
    $VHDPath = "C:\Demo\VHD"
    $VMStartUpMemory = "1024"
    $VMState = "Running"

    Node $NodeName
    {
        OptionalFeature HyperV
        {
            Ensure = "Present"
            Name = "Microsoft-Hyper-V-All"            
        }
      
        VMSwitch InternalSwitch
        {
            Ensure = "Present"
            Name = $SwitchName
            Type = $SwitchType
            Requires = "[OptionalFeature]HyperV"
        }

        File VHDParentFile
        {
            Ensure = "Present"
            DestinationPath = $VHDParentPath
            Type = "File"
            Requires = "[OptionalFeature]HyperV"
        }

        File VHDFolder
        {
            Ensure = "Present"
            DestinationPath = $VHDPath
            Type = "Directory"
            Requires = "[File]VHDParentFile"
        }

        VHD PullServerVhd
        {
            Ensure = "Present"
            Name = $VMName
            Path = $VHDPath
            ParentPath = $VHDParentPath
            Requires = @("[OptionalFeature]HyperV",
                         "[File]VHDFolder")
        }

        VM PullServerVM
        {
            Ensure = "Present"
            Name = $VMName
            VhDPath = "$VHDPath\$VMName"
            SwitchName = $SwitchName
            StartupMemoryMB = $VMStartUpMemory
            State = $VMState
            WaitForIP = $true
            Requires = @("[OptionalFeature]HyperV",
                            "[VMSwitch]InternalSwitch",
                            "[VHD]PullServerVhd")
        }
    }

    Node $VMName
    {
        Computer "Rename$VMName"
        {
            Ensure = "Present"
            Name = $VMName
        }
    }
}

# Create the MOF file for the configuration
PullServerVM 

# Make it happen - First on localhost and then on PullServer
Start-DSCConfiguration -Path $PSScriptRoot\PullServerVM -ComputerName localhost -Wait -Verbose
Start-DSCConfiguration -Path $PSScriptRoot\PullServerVM -ComputerName PullServer -Wait -Verbose

# Restart the VM after rename
Stop-VM PullServer -Passthru | Start-VM