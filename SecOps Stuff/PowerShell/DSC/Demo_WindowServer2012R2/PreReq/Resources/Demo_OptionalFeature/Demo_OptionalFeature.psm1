#
# Generated using tool
# Powershell resource provider for DSC tests.
#
#
# The Get-TargetResource cmdlet.
#
function Get-TargetResource
{
	param
	(
		
		[parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Name,

		[System.String]
		$Ensure
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
		
		[parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Name,

		[System.String]
        [ValidateSet("Present","Absent")]
		$Ensure="Present"
	)
	# Add the logic here.
    if($Ensure -eq "Present")
    {
        Write-Verbose -Message "Enabling feature $Name ..."
        Enable-WindowsOptionalFeature -FeatureName $Name -Online -Verbose:$false
        Write-Verbose -Message "Feature $Name enabled"
    }
    else
    {
        Write-Verbose -Message "Disabling feature $Name ..."
        Disable-WindowsOptionalFeature -FeatureName $Name -Online -Verbose:$false
        Write-Verbose -Message "Feature $Name disabled"
    }
}
#
# The Test-TargetResource cmdlet.
#
function Test-TargetResource
{
	param
	(
		
		[parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Name,

		[System.String]
        [ValidateSet("Present","Absent")]
		$Ensure = "Present"
	)
	# Add the logic here and at the end return either $true or $false.
    If($Ensure -eq "Present"){$State = "Enabled"}
    else{$State = "Disabled"}
    try
    {
        Write-Verbose -Message "Checking if $Name feature is $State ..."
        $feature = Get-WindowsOptionalFeature -Online -FeatureName $Name -Verbose:$false
        Write-Verbose -Message "$Name feature is $($feature.State)"
        ($feature.State -eq $State)
    }
    catch
    {
        Write-Error -Message "Cannot find feature $Name"
        ($Ensure -ne "Present")
    }
}
