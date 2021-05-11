##
## Configures a node to be web server
##
Configuration FourthCoffeeWebsite
{
    Node ("WebServer1","WebServer2")
    {
        # Install the IIS role
        WindowsFeature IIS
        {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        # Install the ASP .NET 4.5 role
        WindowsFeature AspNet45
        {
            Ensure = "Present"
            Name   = "Web-Asp-Net45"
        }
    }
}

# Create the MOF file using the configuration data
FourthCoffeeWebSite

# Make it happen - Copy the MOF files to appropriate nodes and invoke the configuration
Start-DscConfiguration -Path  $PSScriptRoot\FourthCoffeeWebsite -Wait -Verbose -Force