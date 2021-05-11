#
# The Get-TargetResource cmdlet.
#
function Get-TargetResource
{
	param
	(		
		[parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$DomainName,

		[parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$SafeModeAdministratorPassword,

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
		[String]$DomainName,

		[parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$SafeModeAdministratorPassword,

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)

	# Add the logic here.
    if($Ensure -eq "Present")
    {
        Write-Verbose -Message "Installing AD Forest ..."

        Install-ADDSForest -DomainName $DomainName -Force -Verbose:$false `
              -SafeModeAdministratorPassword ($SafeModeAdministratorPassword).password
                    
        Write-Verbose -Message "Installed AD Forest"
        $global:DSCMachineStatus = 1
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
		[String]$DomainName,

		[parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$SafeModeAdministratorPassword,

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)

	# Add the logic here and at the end return either $true or $false.
    Write-Verbose -Message "Checking if AD Forest is installed ..."
    $isADDSForestInstalled = Test-ADDSForestInstallation -DomainName $DomainName -Verbose:$false `
                            -SafeModeAdministratorPassword ($SafeModeAdministratorPassword).password `

    if($isADDSForestInstalled.Status -eq "Error")
    {
        Write-Verbose -Message "AD Forest is already installed"
        $true
    }
    else
    {
        Write-Verbose -Message "AD Forest is not installed"
        $false
    }
}