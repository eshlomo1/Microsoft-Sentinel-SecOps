#
# The Get-TargetResource cmdlet.
#
function Get-TargetResource
{
	param
	(
		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$Name,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$Id,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$StartRange,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$EndRange,

		[ValidateNotNullOrEmpty()]
		[String]$SubnetMask = "255.255.255.0",

		[Int]$LeaseDurationDays = 1,

        [ValidateSet("Bootp", "Both", "Dhcp")]
        [String]$Type = "Dhcp",

        [ValidateSet("Active", "Inactive")]
        [String]$State = "Active",

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
	[CmdletBinding(SupportsShouldProcess)]
    param
	(
		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$Name,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$Id,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$StartRange,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$EndRange,

		[ValidateNotNullOrEmpty()]
		[String]$SubnetMask = "255.255.255.0",

		[Int]$LeaseDurationDays = 1,

        [ValidateSet("Bootp", "Both", "Dhcp")]
        [String]$Type = "Dhcp",

        [ValidateSet("Active", "Inactive")]
        [String]$State = "Active",

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)

	# Add the logic here.
    try
    {
        Write-Verbose -Message "Checking DHCP scope ..."
        $dhcpScope = Get-DhcpServerv4Scope -ScopeId $ID -ErrorAction Stop

        #If dhcpScope is set, test individual properties to match parameter values
        if($dhcpScope)
        {
            Write-Verbose -Message "DHCP Scope is present"

            # Remove $Ensure from PSBoundParameters and pass it to validateProperties helper function
            If($PSBoundParameters.ContainsKey("Ensure")){$null = $PSBoundParameters.Remove("Ensure")}

            ValidateProperties -DhcpScope $dhcpScope @PSBoundParameters -Apply
        }
    }
    catch
    {
        Write-Verbose -Message "DHCP Scope is not present"
        Write-Verbose -Message "Adding DHCP Scope ..."

        Add-DhcpServerv4Scope -Name $Name -State $State  -Type $Type `
                              -StartRange $StartRange -EndRange $EndRange -SubnetMask $SubnetMask `
                              -LeaseDuration (New-TimeSpan -Days $LeaseDurationDays)

        Write-Verbose -Message "DHCP Scope added"
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
		[String]$Name,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$Id,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$StartRange,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$EndRange,

		[ValidateNotNullOrEmpty()]
		[String]$SubnetMask = "255.255.255.0",

		[Int]$LeaseDurationDays = 1,

        [ValidateSet("Bootp", "Both", "Dhcp")]
        [String]$Type = "Dhcp",

        [ValidateSet("Active", "Inactive")]
        [String]$State = "Active",

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)

	# Add the logic here and at the end return either $true or $false.

    # TODO: Handle the absent case
    try
    {
        Write-Verbose -Message "Checking DHCP scope ..."
        $dhcpScope = Get-DhcpServerv4Scope -ScopeId $ID -ErrorAction Stop

        #If dhcpScope is set, test individual properties to match parameter values
        if($dhcpScope)
        {
            Write-Verbose -Message "DHCP Scope is present"

            # Remove $Ensure from PSBoundParameters and pass it to validateProperties helper function
            If($PSBoundParameters.ContainsKey("Ensure")){$null = $PSBoundParameters.Remove("Ensure")}

            ValidateProperties -DhcpScope $dhcpScope @PSBoundParameters
        }
    }
    catch
    {
        Write-Verbose -Message "DHCP Scope is not present"
        $false
    }
}

function ValidateProperties
{
    param
	(
		[parameter(Mandatory)]
		[ValidateNotNull()]
		[Microsoft.Management.Infrastructure.CimInstance]$DhcpScope,
        
		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$Name,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$Id,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$StartRange,

		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$EndRange,

		[ValidateNotNullOrEmpty()]
		[String]$SubnetMask,

		[Int]$LeaseDurationDays,

        [ValidateSet("Bootp", "Both", "Dhcp")]
        [String]$Type,

        [ValidateSet("Active", "Inactive")]
        [String]$State,

		[Switch]$Apply
	)

    # Test the scope name
    Write-Verbose -Message "Checking DHCP Scope Name ..."
    if($dhcpScope.Name -ne $Name) 
    {
        Write-Verbose -Message "DHCP Scope Name is not correct. Expected $Name, actual $dhcpScope.Name"
        if($Apply)
        {
            Set-DhcpServerv4Scope -ScopeId $Id -Name $Name
            Write-Verbose -Message "DHCP Scope Name is set to $Name."
        }
        else{return $false}
    }
    else
    {
        Write-Verbose -Message "DHCP Scope Name is correct."
    }
            
    # Test the Start Range
    Write-Verbose -Message "Checking DHCP Scope Start Range ..."
    if($dhcpScope.StartRange -ne $StartRange) 
    {
        Write-Verbose -Message "DHCP Scope Start Range is not correct. Expected $StartRange, actual $dhcpScope.StartRange"
        if($Apply)
        {
            Set-DhcpServerv4Scope -ScopeId $Id -StartRange $StartRange
            Write-Verbose -Message "DHCP Scope Start Range is set to $StartRange."
        }
        else{ return $false}
    }
    else
    {
        Write-Verbose -Message "DHCP Scope Start Range is correct."
    }

    # Test the End Range
    Write-Verbose -Message "Checking DHCP Scope End Range ..."
    if($dhcpScope.EndRange -ne $EndRange) 
    {
        Write-Verbose -Message "DHCP Scope End Range is not correct. Expected $EndRange, actual $dhcpScope.EndRange"
        if($Apply)
        {
            Set-DhcpServerv4Scope -ScopeId $Id -EndRange $EndRange
            Write-Verbose -Message "DHCP Scope End Range is set to $EndRange."
        }
        else{return $false}
    }
    else
    {
        Write-Verbose -Message "DHCP Scope End Range is correct."
    }

    # Test the Subnet Mask
    Write-Verbose -Message "Checking DHCP Scope Subnet Mask ..."
    if($dhcpScope.SubnetMask.IPAddressToString -ne $SubnetMask)
    {
        Write-Verbose -Message "DHCP Scope Subnet Mask is not correct. Expected $SubnetMask, actual $dhcpScope.SubnetMask"
        if($Apply)
        {
            # To set teh subnet mask scope, the only ways is to remove the old scope
            # Add create a new scope
            Remove-DhcpServerv4Scope -ScopeId $Id

            Add-DhcpServerv4Scope -Name $Name -State $State  -Type $Type `
                                  -StartRange $StartRange -EndRange $EndRange `
                                  -SubnetMask $SubnetMask `
                                  -LeaseDuration (New-TimeSpan -Days $LeaseDurationDays)

            Write-Verbose -Message "DHCP Scope Subnet Mask is set to $SubnetMask."
        }
        else{return $false}
    }
    else
    {
        Write-Verbose -Message "DHCP Scope Subnet Mask is correct."
    }

    # Test the Lease duration
    $LeaseDuration = (New-TimeSpan -Days $LeaseDurationDays)
    Write-Verbose -Message "Checking DHCP Scope Lease Duration ..."
    if($dhcpScope.LeaseDuration -ne $LeaseDuration) 
    {
        Write-Verbose -Message "DHCP Scope Lease Duration is not correct. Expected $LeaseDuration, actual $dhcpScope.LeaseDuration"
        if($Apply)
        {
            Set-DhcpServerv4Scope -ScopeId $Id -LeaseDuration $LeaseDuration 
            Write-Verbose -Message "DHCP Scope Lease Duration is set to $LeaseDuration."
        }
        else{return $false}
    }
    else
    {
        Write-Verbose -Message "DHCP Scope Lease Duration is correct."
    }

    # Test the Scope Type
    Write-Verbose -Message "Checking DHCP Scope Type ..."
    if($dhcpScope.Type -ne $Type) 
    {
        Write-Verbose -Message "DHCP Scope Type is not correct. Expected $Type, actual $dhcpScope.Type"
        if($Apply)
        {
            Set-DhcpServerv4Scope -ScopeId $Id -Type $Type
            Write-Verbose -Message "DHCP Scope Type is set to $Type."
        }
        else{return $false}
    }
    else
    {
        Write-Verbose -Message "DHCP Scope Type is correct."
    }

    # Test the Scope State
    Write-Verbose -Message "Checking DHCP Scope State ..."
    if($dhcpScope.State -ne $State) 
    {
        Write-Verbose -Message "DHCP Scope State is not correct. Expected $State, actual $dhcpScope.State"
        if($Apply)
        {
            Set-DhcpServerv4Scope -ScopeId $Id -State $State
            Write-Verbose -Message "DHCP Scope State is set to $State."
        }
        else{return $false}
    }
    else
    {
        Write-Verbose -Message "DHCP Scope State is correct."
    }

    if(! $Apply){$true}
}