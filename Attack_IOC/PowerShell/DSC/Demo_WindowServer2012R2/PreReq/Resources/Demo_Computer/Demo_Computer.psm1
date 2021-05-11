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
	
		[ValidateNotNullOrEmpty()]
		[String]$DomainName,

        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential,

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
		[String]$Name,
	
		[ValidateNotNullOrEmpty()]
		[String]$DomainName,

        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential,

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)

	# Add the logic here.

    # Find computer properties
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem -Verbose:$false

    # Remove $Ensure from PSBoundParameters and pass it to validateProperties helper function
    If($PSBoundParameters.ContainsKey("Ensure")){$null = $PSBoundParameters.Remove("Ensure")}

    ValidateProperties -Computer $computer @PSBoundParameters -Apply
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
	
		[ValidateNotNullOrEmpty()]
		[String]$DomainName,

        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential,

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
	)

	# Add the logic here and at the end return either $true or $false.

    Write-Verbose -Message "Checking Computer Properties ..."
    # Find computer properties
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem -Verbose:$false

    # Remove $Ensure from PSBoundParameters and pass it to validateProperties helper function
    If($PSBoundParameters.ContainsKey("Ensure")){$null = $PSBoundParameters.Remove("Ensure")}

    ValidateProperties -Computer $computer @PSBoundParameters
}

function ValidateProperties
{
    param
	(	
        [parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[Microsoft.Management.Infrastructure.CimInstance]$Computer,

        [parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$Name,
	
		[ValidateNotNullOrEmpty()]
		[String]$DomainName,

        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential,

        [Switch]$Apply
	)

    $RenameComputer = $false
    $JoinDomain = $false
        
    # Test the Computer name
    Write-Verbose -Message "Checking Computer Name ..."
    if($Computer.Name -ne $Name) 
    {
        Write-Verbose -Message "Computer Name is not correct. Expected $Name, actual $($Computer.Name)"
        if($Apply)
        {
            $RenameComputer = $true
        }
        else{return $false}
    }
    else
    {
        Write-Verbose -Message "Computer Name is correct."
    }
            
    # Test the Domain
    Write-Verbose -Message "Checking Domain Name ..."
    if($PSBoundParameters.ContainsKey("DomainName") -and ($Computer.Domain -notcontains $DomainName))
    {
        Write-Verbose -Message "Computer domain is not correct. Expected $DomainName, actual $($Computer.domain)"
        if($Apply)
        {
            $JoinDomain = $true
        }
        else{ return $false}
    }
    else
    {
        Write-Verbose -Message "Computer domain is correct."
    }

    If($Apply)
    {
        # If ONLY domain is not right, command will be Add-Computer with -DomainName and -Credential
        # If ONLY name is not right, command will be Rename-Computer with -NewName
        # If BOTH name and domain are not right, command will be Add-Computer with -DomainName, -Credential and -NewName
        $parameters = @{}
        if($JoinDomain)
        {
            $commandName = "Add-Computer"
            if($PSBoundParameters.ContainsKey("DomainName"))
            {
                $parameters["DomainName"]=$DomainName
            }
            if($PSBoundParameters.ContainsKey("Credential"))
            {
                $parameters["Credential"]=$Credential
            }

            if($RenameComputer)
            {
                $parameters["NewName"]=$Name
            }
        }
        elseif($RenameComputer)
        {
            $commandName = "Rename-Computer"
            $parameters["NewName"]=$Name
        }   

        # Invoke the command with splatting its parameters
        & $commandName @parameters

        # Tell the DSC Engine to restart the machine
        $global:DSCMachineStatus = 1

        if($JoinDomain){ Write-Verbose -Message "Computer domain is set to $DomainName" }
        if($RenameComputer){ Write-Verbose -Message "Computer name is set to $Name"}
    }
    else{ $true}
}