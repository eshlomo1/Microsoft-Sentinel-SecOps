param
(
    # Configuration File that defines the environmental data
    [Parameter(Position=0,Mandatory)]
    [Int]$WebServerCount
)

# List of web servers
$WebServers = 1..$WebServerCount | % {"WebServer$_"}

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

    # Import the module that defines a configuration
    Import-Module Web-VM

    # Call the configuration like any other resource
    # Create the VMs for Web role
    WebVM VMs
    {
        WebServerCount = $WebServerCount
    }

    Node $NodeName
    {
        # Install the IIS role
        WindowsFeature IIS
        {
            Ensure="Present"
            Name="Web-Server"
        }

        # Install the ASP .NET 4.5 role
        WindowsFeature AspNet45
        {
            Ensure="Present"
            Name="Web-Asp-Net45"
        }

        # Stop the default website
        Website DefaultSite 
        {
            Ensure = "Present"
            Name="Default Web Site"
            State = "Stopped"
            PhysicalPath="C:\inetpub\wwwroot"
            Requires = "[WindowsFeature]IIS"
        }

        # Copy the website content
        File WebContent
        {
            Ensure="Present"
            SourcePath= $SourcePath
            DestinationPath= $DestinationPath
            Recurse=$true
            Type="Directory"
            Requires = "[WindowsFeature]AspNet45"
        }       

        # Create the new Website
        Website BakeryWebSite 
        {
            Ensure = "Present"
            Name=$WebSiteName
            State = "Started"
            PhysicalPath=$DestinationPath
            Requires = "[File]WebContent"
        }
    }
}

# Create the MOF file using the configuration data
FourthCoffeeWebSite -NodeName "WebServer1","WebServer2" -WebSiteName "FourthCoffee" `
                    -SourcePath "C:\BakeryWebsite\" -DestinationPath "C:\inetpub\FourthCoffee"

# Make it happen - Copy the MOF files to appropriate nodes and invoke the configuration
Start-DSCConfiguration -ComputerName localhost -Path $PSScriptRoot\FourthCoffeeWebsite -Wait -Verbose -Force

# Once VMs are created, push the configuration to webservers and invoke it
Start-DSCConfiguration -ComputerName $WebServers -Path $PSScriptRoot\FourthCoffeeWebsite -Wait -Verbose -Force

# Restart the Webservers after machine rename
"Restarting the $WebServers"
Stop-VM -Name $WebServers -Force -Passthru | Start-VM

# Wait for VM connectivity
$WebServers | % {Get-VMIPAddress -Name $psitem}

# Continue the configuration on webservers
Start-DSCConfiguration -ComputerName $WebServers -Path $PSScriptRoot\FourthCoffeeWebsite -Wait -Verbose -Force