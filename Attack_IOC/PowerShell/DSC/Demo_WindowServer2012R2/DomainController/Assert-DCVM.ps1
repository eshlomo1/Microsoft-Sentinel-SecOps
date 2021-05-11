##
## Setup a VM for DC and DHCP role
##
Configuration DCVM
{
    Node "localhost"
    {
        OptionalFeature HyperV
        {
            Ensure          = "Present"
            Name            = "Microsoft-Hyper-V-All"            
        }
      
        VMSwitch VirtualSwitch
        {
            Ensure          = "Present"
            Name            = "Internal" 
            Type            = "Internal" 
            Requires        = "[OptionalFeature]HyperV"
        }

        File VhdParentFile
        {
            Ensure          = "Present"
            DestinationPath = "C:\Demo\VHD\Library\LibDC.vhd"
            Type            = "File"
            Requires        = "[OptionalFeature]HyperV"
        }

        File VHDFolder
        {
            Ensure          = "Present"
            DestinationPath = "C:\Demo\VHD"
            Type            = "Directory"
            Requires        = "[File]VHDParentFile"
        }

        VHD DCVhd
        {
            Ensure          = "Present"
            Name            = "DC"
            Path            = "C:\Demo\VHD"
            ParentPath      = "C:\Demo\VHD\Library\LibDC.vhd"
            Requires        = @("[OptionalFeature]HyperV",
                                "[File]VHDFolder")
        }

        VM DCVM
        {
            Ensure          = "Present"
            Name            = "DC"
            VhDPath         = "C:\Demo\VHD\DC"
            SwitchName      = "Internal"
            StartupMemoryMB = 1024
            State           = "Running"
            WaitForIP       = $true
            Requires        = @("[OptionalFeature]HyperV",
                                "[VMSwitch]VirtualSwitch",
                                "[VHD]DCVhd")
        }
    }
}

# Create the MOF file for the configuration
DCVM

# Make it happen
Start-DSCConfiguration -Path $PSScriptRoot\DCVM -Wait -Verbose -Force