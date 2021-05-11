#
# The Get-TargetResource cmdlet.
#
function Get-TargetResource
{
	param
    (
        # Name of the VHD files
        [Parameter(Mandatory)]
        [string]$Name,

        # Location where the VHD will be created 
        [Parameter(Mandatory)]
        [string]$Path,

        # Parent VHD path, for differencing disk
        [Parameter(Mandatory)]
        [string]$ParentPath,
        
        # Should the VHD be created or deleted
        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present"
    )
	# Add the logic here and at the end return hashtable of properties.

    # If the name doesn't ends with .vhd, add to it
    If(! $Name.EndsWith(".vhd")){$Name = $Name+".vhd"}

    # Construct the full path for the vhdFile
    $vhdFilePath = Join-Path -Path $Path -ChildPath $Name
    try
    {
        $vhd = Get-VHD -Path $vhdFilePath
        @{
            $Name = $Name
            Path=$vhd.Path
            ParentPath = $vhd.ParentPath
            Format = $vhd.VhdFormat
            Type = $vhd.VhdType
            Size = $vhd.FileSize
            TotalSize = $vhd.Size
            Attached = $vhd.Attached
            Ensure = $Ensure
        }
    }
    catch{
        Write-Error -Message "Vhd with name $Name is not present at $vhdFilePath"
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
        # Name of the VHD files
        [Parameter(Mandatory)]
        [string]$Name,

        # Location where the VHD will be created 
        [Parameter(Mandatory)]
        [string]$Path,

        # Parent VHD path, for differencing disk
        [Parameter(Mandatory)]
        [string]$ParentPath,
        
        # Should the VHD be created or deleted
        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present"
    )

	# Add the logic here.

    # If the name doesn't ends with .vhd, add to it
    If(! $Name.EndsWith(".vhd")){$Name = $Name+".vhd"}

    # Construct the full path for the vhdFile
    $vhdFilePath = Join-Path -Path $Path -ChildPath $Name

    Write-Verbose -Message "Checking if $vhdFilePath is $Ensure ..."

    # Check if the Vhd is present
    try
    {
        $vhd = Get-VHD -Path $vhdFilePath -ErrorAction Stop

        # If vhd should be absent, delete it
        if($Ensure -eq "Absent")
        {
            Write-Verbose -Message "$vhdFilePath is not $Ensure"
            Remove-Item -Path $vhdFilePath -Force
            Write-Verbose -Message "$vhdFilePath is now $Ensure"
        }
        # If vhd is present, check the parent path
        else
        {
            Write-Verbose -Message "$vhdFilePath is $Ensure"
            Write-Verbose -Message "Checking if $vhdFilePath parent path is $ParentPath ..."
            # If the parent path is not set correct, fix it
            if($vhd.ParentPath -ne $ParentPath)
            {
                Write-Verbose -Message "$vhdFilePath parent path is not $ParentPath."
                Set-VHD -Path $vhdFilePath -ParentPath $ParentPath
                Write-Verbose -Message "$vhdFilePath parent path is now $ParentPath."
            }
            else
            {
                Write-Verbose -Message "$vhdFilePath is $Ensure and parent path is set to $ParentPath."                
            }
        }
    }

    # Vhd file is not present
    catch
    {
        if($Ensure -eq "Present")
        {
            Write-Verbose -Message "$vhdFilePath is not $Ensure"
            $null = New-VHD -Path $vhdFilePath -ParentPath $ParentPath
            Write-Verbose -Message "$vhdFilePath is now $Ensure"
        }
        else
        {
            Write-Verbose -Message "$vhdFilePath is already $Ensure"
        }
    }
}

#
# The Test-TargetResource cmdlet.
#
function Test-TargetResource
{
	param
    (
        # Name of the VHD files
        [Parameter(Mandatory)]
        [string]$Name,

        # Location where the VHD will be created 
        [Parameter(Mandatory)]
        [string]$Path,

        # Parent VHD path, for differencing disk
        [Parameter(Mandatory)]
        [string]$ParentPath,
        
        # Should the VHD be created or deleted
        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present"
    )

    # Do input validation
    $source = Test-Path -Path $ParentPath
    $destination = Test-Path -Path $Path 
    if(! $source){throw "$ParentPath does not exists"}
    if(! $destination){throw "$Path does not exists"}

    # If the name doesn't ends with .vhd, add to it
    If(! $Name.EndsWith(".vhd")){$Name = $Name+".vhd"}

    $result = $false

    # Construct the full path for the vhdFile
    $vhdFilePath = Join-Path -Path $Path -ChildPath $Name

	# Add the logic here and at the end return either $true or $false.
    return Test-VHD -Path $vhdFilePath -ErrorAction SilentlyContinue
}
