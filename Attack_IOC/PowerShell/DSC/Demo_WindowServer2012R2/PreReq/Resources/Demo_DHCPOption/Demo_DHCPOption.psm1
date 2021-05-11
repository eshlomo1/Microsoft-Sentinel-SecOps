#
# The Get-TargetResource cmdlet.
#
function Get-TargetResource
{
	param
	(		
		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String] $DNSServerName,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String] $DomainName,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String] $Router,

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
		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String] $DNSServerName,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String] $DomainName,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String] $Router,

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)

	# Add the logic here.
    Write-Verbose -Message "Checking DHCP Option ..."
    $dhcpOption = Get-DhcpServerv4OptionValue

    #If dhcpOption is set, test individual properties to match parameter values
    if($dhcpOption)
    {
        Write-Verbose -Message "DHCP Option is present"

        # Remove $Ensure from PSBoundParameters and pass it to validateProperties helper function
        If($PSBoundParameters.ContainsKey("Ensure")){$null = $PSBoundParameters.Remove("Ensure")}

        $PSBoundParameters
        ValidateProperties -DhcpOption $dhcpOption @PSBoundParameters -Apply
    }
    else
    {
        Write-Verbose -Message "DHCP Options are not present"
        Write-Verbose -Message "Adding DHCP Options ..."
        
        Set-DhcpServerv4OptionValue -DnsServer $DNSServerName `
                                    -DnsDomain $DomainName -Router $Router

        Write-Verbose -Message "DHCP options are set" 
    }
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
		[String] $DNSServerName,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String] $DomainName,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String] $Router,

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)

    $result = $false

	# Add the logic here and at the end return either $true or $false.

    # TODO: Handle the absent case
    try
    {
        Write-Verbose -Message "Checking DHCP options ..."
        $dhcpOption = Get-DhcpServerv4OptionValue

        #If dhcpScope is set, test individual properties to match parameter values
        if($dhcpOption)
        {
            Write-Verbose -Message "DHCP Options are present"

            # Remove $Ensure from PSBoundParameters and pass it to validateProperties helper function
            If($PSBoundParameters.ContainsKey("Ensure")){$null = $PSBoundParameters.Remove("Ensure")}
            ValidateProperties -DhcpOption $dhcpOption @PSBoundParameters
        }
        else
        {
            $result
        }
    }
    catch
    {
        $_
        Write-Verbose -Message "DHCP Options are not present"
        $result
    }
}

function ValidateProperties
{
    param
    (
        [parameter(Mandatory)]
		[ValidateNotNull()]
		[Microsoft.Management.Infrastructure.CimInstance[]]$DhcpOption,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String] $DNSServerName,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String] $DomainName,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String] $Router,

		[Switch]$Apply
    )

    # Test the DNS Server Name
    Write-Verbose -Message "Checking DHCP DNS Name ..."
    $var = ($DhcpOption | ? Name -like "*Server*").value
    if( $var -ne $DNSServerName) 
    {
        Write-Verbose -Message "DHCP Server Name is not correct. Expected $DNSServerName, actual $var"
        if($Apply)
        {
            Write-Verbose -Message "Setting DHCP Server Name ..."
            Set-DhcpServerv4OptionValue -DnsServer $DNSServerName
            Write-Verbose -Message "DHCP Server Name is set to $DNSServerName." -Verbose
        }
        else{return $false}
    }
    else
    {
        Write-Verbose -Message "DHCP Server Name is correct."
    }
            
    # Test the Domain Name
    Write-Verbose -Message "Checking DHCP Domain Name ..."
    $var = ($DhcpOption | ? Name -like "*Domain*Name*").value
    if($var -ne $DomainName) 
    {
        Write-Verbose -Message "DHCP Domain Name is not correct. Expected $DomainName, actual $var"
        if($Apply)
        {
            Write-Verbose -Message "Setting DHCP Domain Name ..."
            Set-DhcpServerv4OptionValue -DnsDomain $DomainName
            Write-Verbose -Message "DHCP Domain Name is set to $DomainName."
        }
        else{ return $false}
    }
    else
    {
        Write-Verbose -Message "DHCP Domain Name is correct."
    }

    # Test the Router
    Write-Verbose -Message "Checking DHCP Router ..."
    $var = ($DhcpOption | ? Name -like "*Router*").value
    if($var -ne $Router) 
    {
        Write-Verbose -Message "DHCP Router is not correct. Expected $Router, actual $var"
        if($Apply)
        {
            Write-Verbose -Message "Setting DHCP Router ..."
            Set-DhcpServerv4OptionValue -Router $Router
            Write-Verbose -Message "DHCP Router is set to $Router."
        }
        else{return $false}
    }
    else
    {
        Write-Verbose -Message "DHCP Router is correct."
    }
    
    if(! $Apply){$true}
}