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

        [ValidateSet("Internal", "Private")]
        [String]$Type = "Internal",

		[ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
    )
	# Add the logic here and at the end return hashtable of properties.
    try
    {
        $switch = Get-VMSwitch -Name $Name
        @{
            Name=$switch.Name
            Type=$switch.SwitchType
            AllowManagementOS = $switch.AllowManagementOS
            Ensure = $Ensure
        }
    }
    catch{
        Write-Error -Message "Switch with name $Name is not present"
    }
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

        [ValidateSet("Internal", "Private")]
        [String]$Type = "Internal",

		[ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)

	# Add the logic here.
    if($Ensure -eq 'Present')
    {
        $switch = (Get-VMSwitch -Name $Name -ErrorAction SilentlyContinue)
        # If the switch is not present, create one
        if(! $switch )
        {
            Write-Verbose -Message "Switch $Name is not $Ensure."
            Write-Verbose -Message "Creating Switch ..."
            $null = New-VMSwitch -Name $Name -SwitchType $Type
            Write-Verbose -Message "Switch $Name is now $Ensure."
        }
        # If switch is present, that means it is not the right type (TEST code ensures that)
        else
        {
            Write-Verbose -Message "Switch type is not correct. Expected $Type, Actual $switch.SwitchType"
            Write-Verbose -Message "Setting Switch type ..."
            Set-VMSwitch -Name $Name -SwitchType $Type
            Write-Verbose -Message "Switch type is now $Type"
        }
    }
    # Ensure is set to "Absent", remove the switch
    else
    {
        Get-VMSwitch $Name -ErrorAction SilentlyContinue | Remove-VMSwitch -Force
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

        [ValidateSet("Internal", "Private")]
        [String]$Type = "Internal",

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)

	# Add the logic here and at the end return either $true or $false.
    try
    {
        # Check if switch exists
        Write-Verbose -Message "Checking if Switch $Name is $Ensure ..."
        $switch = Get-VMSwitch -Name $Name -ErrorAction Stop

        # If switch exists
        if($switch)
        {
            Write-Verbose -Message "Switch $Name is Present"
            # If switch should be present, check the switch type
            if($Ensure -eq 'Present')
            {
                # If switch is the required type, return $true, else $false
                return ($switch.SwitchType -eq $Type)
            }
            # If switch should be absent, but is there, return $false
            else
            {
                return $false
            }
        }
        # This code should never be hit
        else
        {
            Write-Warning -Message "This code should never be hit"
            return $false
        }
    }

    # If checking for switch throws, means switch is not present
    catch
    {
        Write-Verbose -Message "Switch $Name is not Present"
        return ($Ensure -ne 'Present')
    }
}
