##
## Configures a node to be web server and creates a new website
##
Configuration FourthCoffeeWebsite
{
    param
    (
        # Target nodes to apply the configuration
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String[]]$NodeName,

        # Name of the website to create
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$WebSiteName,

        # Source Path for Website content
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$SourcePath,

        # Destination path for Website content
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$DestinationPath
    )

    Node $NodeName
    {
        # Install the IIS role
        WindowsFeature IIS
        {
            Ensure          = "Present"
            Name            = "Web-Server"
        }

        # Install the ASP .NET 4.5 role
        WindowsFeature AspNet45
        {
            Ensure          = "Present"
            Name            = "Web-Asp-Net45"
        }

        # Stop the default website
        Website DefaultSite 
        {
            Ensure          = "Present"
            Name            = "Default Web Site"
            State           = "Stopped"
            PhysicalPath    = "C:\inetpub\wwwroot"
            Requires        = "[WindowsFeature]IIS"
        }

        # Copy the website content
        File WebContent
        {
            Ensure          = "Present"
            SourcePath      = $SourcePath
            DestinationPath = $DestinationPath
            Recurse         = $true
            Type            = "Directory"
            Requires        = "[WindowsFeature]AspNet45"
        }       

        # Create the new Website
        Website BakeryWebSite 
        {
            Ensure          = "Present"
            Name            = $WebSiteName
            State           = "Started"
            PhysicalPath    = $DestinationPath
            Requires        = "[File]WebContent"
        }
    }
}

# Create the MOF file using the configuration data
FourthCoffeeWebSite -NodeName "WebServer1","WebServer2" -WebSiteName "FourthCoffee" `
                    -SourcePath "C:\BakeryWebsite\" -DestinationPath "C:\inetpub\FourthCoffee"

# Make it happen - Copy the MOF files to appropriate nodes and invoke the configuration
Start-DscConfiguration -Path  $PSScriptRoot\FourthCoffeeWebsite -Wait -Verbose -Force