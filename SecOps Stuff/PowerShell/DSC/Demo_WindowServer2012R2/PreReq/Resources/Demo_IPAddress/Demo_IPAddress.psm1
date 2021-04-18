#
# The Get-TargetResource cmdlet.
#
function Get-TargetResource
{
	param
	(		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$IPAddress,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Int]$PrefixLength = 24,

		[ValidateNotNullOrEmpty()]
        [String]$DefaultGateway,

        [ValidateSet("IPv4", "IPv6")]
        [String]$AddressFamily = "IPv4",

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)
	# Add the logic here and at the end return hashtable of properties.
}

#
# The Set-TargetResource cmdlet.
#
function Set-TargetResource
{
	param
	(		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$IPAddress,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Int]$PrefixLength = 24,

		[ValidateNotNullOrEmpty()]
        [String]$DefaultGateway,

        [ValidateSet("IPv4", "IPv6")]
        [String]$AddressFamily = "IPv4",

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)

	# Add the logic here.
    try
    {
        Write-Verbose -Message "Checking the IPAddress ..."
        $currentIP = Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily $AddressFamily -ErrorAction Stop

        # Remove $Ensure from PSBoundParameters and pass it to validateProperties helper function
        If($PSBoundParameters.ContainsKey("Ensure")){$null = $PSBoundParameters.Remove("Ensure")}

        ValidateProperties -currentIP $currentIP -IPAddress $IPAddress `
                           -InterfaceAlias $InterfaceAlias -DefaultGateway $DefaultGateway `
                           -PrefixLength $PrefixLength -Apply
    }
    catch
    {
        throw "Should never reach here"
    }
}

#
# The Test-TargetResource cmdlet.
#
function Test-TargetResource
{
	param
	(		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$IPAddress,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Int]$PrefixLength = 24,

		[ValidateNotNullOrEmpty()]
        [String]$DefaultGateway,

        [ValidateSet("IPv4", "IPv6")]
        [String]$AddressFamily = "IPv4",

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)

	# Add the logic here and at the end return either $true or $false.
    try
    {
        Write-Verbose -Message "Checking the IPAddress ..."
        $currentIP = Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily $AddressFamily -ErrorAction Stop

        # Remove $Ensure from PSBoundParameters and pass it to validateProperties helper function
        If($PSBoundParameters.ContainsKey("Ensure")){$null = $PSBoundParameters.Remove("Ensure")}

        ValidateProperties -currentIP $currentIP -IPAddress $IPAddress `
                           -InterfaceAlias $InterfaceAlias -DefaultGateway $DefaultGateway `
                           -PrefixLength $PrefixLength
    }
    catch
    {
       Write-Verbose -Message $_
       throw "Can not find valid IPAddress using InterfaceAlia $InterfaceAlias and AddressFamily $AddressFamily"
    }
}

function ValidateProperties
{
    param
    (
        [Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[Microsoft.Management.Infrastructure.CimInstance]$currentIP,

        [Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$IPAddress,

		[ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [ValidateNotNullOrEmpty()]
        [String]$DefaultGateway,

        [Int]$PrefixLength,

        [Switch]$Apply
    )

    if($currentIP.IPAddress -ne $IPAddress)
    {
        Write-Verbose -Message "IPAddress not correct. Expected $IPAddress, actual $($currentIP.IPAddress)"
        if($Apply)
        {
            Write-Verbose -Message "Setting IPAddress ..."
            $null = $currentIP | New-NetIPAddress -IPAddress $IPAddress -DefaultGateway $DefaultGateway -PrefixLength $PrefixLength
            # Set the DNS settings as well
            Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DefaultGateway
            # Make the connection profile private
            Get-NetConnectionProfile -InterfaceAlias $InterfaceAlias | Set-NetConnectionProfile -NetworkCategory Private -ErrorAction SilentlyContinue
            Write-Verbose -Message "IPAddress is set to $IPAddress."
        }
        else {return $false}
    }
    else
    {
        Write-Verbose -Message "IPAddress is correct."
        return $true
    }
}