#
# The Get-TargetResource cmdlet.
#
function Get-TargetResource
{
	param
	(
		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$DNSName,

		[ValidateNotNullOrEmpty()]
		[String]$IPAddress,

        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present"
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
		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$DNSName,

		[ValidateNotNullOrEmpty()]
		[String]$IPAddress,

        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present"
	)

	# Add the logic here.
    if($PSBoundParameters.ContainsKey("Ensure")){$null = $PSBoundParameters.Remove("Ensure")}
    if($PSBoundParameters.ContainsKey("Debug")){$null = $PSBoundParameters.Remove("Debug")}

    Write-Verbose -Message "Adding DHCP server in DC ..."
    Add-DhcpServerInDC @PSBoundParameters
    Write-Verbose -Message "DHCP server is added in DC"
 
}

#
# The Test-TargetResource cmdlet.
#
function Test-TargetResource
{
    param
	(
		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$DNSName,

		[ValidateNotNullOrEmpty()]
		[String]$IPAddress,

        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present"
	)

	# Add the logic here and at the end return either $true or $false.

    # TODO: Handle the absent case
    Write-Verbose -Message "Checking if DHCP server is in DC ..."
    try
    {
        $dhcpInDC = Get-DhcpServerInDC

        if($dhcpInDC)
        {
            Write-Verbose -Message "DHCP server $env:COMPUTERNAME is already added in DC"
            return $true
        }
        else
        {
            Write-Verbose -Message "DHCP server $env:COMPUTERNAME is NOT added in DC"
            return $false
        }
    }
    catch
    {
        Write-Verbose -Message "DHCP server $env:COMPUTERNAME is NOT added in DC"
        return $false
    }
}