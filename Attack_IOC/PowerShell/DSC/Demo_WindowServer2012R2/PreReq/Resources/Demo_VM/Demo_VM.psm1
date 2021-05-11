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
            [String]$VhDPath,

            [parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [String]$SwitchName,

            [Boolean]$WaitForIP=$false,

            [ValidateNotNullOrEmpty()]
            [Int]$StartupMemoryMB = "512",

            [ValidateSet("Running", "Paused", "Off")]
            [String]$State = "Running",

            [ValidateSet("Present", "Absent")]
            [String]$Ensure = "Present"
        )

	# Add the logic here and at the end return hashtable of properties.
    try
    {
        $vm = Get-VM -Name $Name -ErrorAction Stop
        $vmState = $vm.state
        $vmId = $vm.Id
        $vmStatus = $vm.Status
        $vmCPU = $vm.CPUUsage
        $vmMemoryAssigned = $vm.MemoryAssigned
        $vmMemoryStartup = $vm.MemoryStartup
        $vmUpTime = $vm.Uptime
        $vmCreationTime = $vm.CreationTime
        $vmDynamicMemory = $vm.DynamicMemoryEnabled
        $vmProcessorCount = $vm.ProcessorCount
        $vmNetworkAdapters = $vm.NetworkAdapters
    }
    catch{}

    @{
        Name=$vm.Name;
        State = $vmState
        Id = $vmId
        Status = $vmStatus
        CPUUsage = $vmCPU
        MemoryAssigned = $vmMemoryAssigned
        MemoryStartup = $vmMemoryStartup
        Uptime = $vmUpTime
        Creationtime = $vmCreationTime
        DynamicMemoryEnabled = $vmDynamicMemory
        ProcessorCount = $vmProcessorCount
        NetworkAdapters = $vmNetworkAdapters
    }    
}

#
# The Set-TargetResource cmdlet.
#
function Set-TargetResource
{
	[CmdletBinding(SupportsShouldProcess=$true)]
    param
	(	
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$VhDPath,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$SwitchName,

        [Boolean]$WaitForIP=$false,

        [ValidateNotNullOrEmpty()]
        [Int]$StartupMemoryMB = "512",

        [ValidateSet("Running", "Paused", "Off")]
        [String]$State = "Running",

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
    )

    # If the VhdPath doesn't ends with .vhd, add to it
    If(! $VhDPath.EndsWith(".vhd")){$VhDPath = $VhDPath+".vhd"}
    
    Write-Verbose -Message "Checking if VM $Name exists ..."
    $vmObj = Get-VM -Name $Name -ErrorAction SilentlyContinue

    # VM already exists
    if($vmObj)
    {
        Write-Verbose -Message "VM $Name exists"
        # If VM shouldn't be there, stop it and remove it
        if($Ensure -eq "Absent")
        {
            Write-Verbose -Message "VM $Name should be $Ensure"
            Get-VM $Name | Stop-VM -Force -Passthru -WarningAction SilentlyContinue | Remove-VM -Force
            Write-Verbose -Message "VM $Name is $Ensure"
        }
        # If VM is present, check its state, startup memory
        # One cannot set the VM's vhdpath and switch type after creation 
        else
        {
            # If the VM is not in right state, set it to right state
            if($vmObj.State -ne $State)
            {
                Write-Verbose -Message "VM $Name is not $State"
                SetVMState -Name $Name -State $State
                Write-Verbose -Message "VM $Name is now $State"
            }
            # If the VM does not have the right startup memory, stop the VM, set the right memory, start the VM
            if(($vmObj.MemoryStartup)/1MB -ne $StartupMemoryMB)
            {
                Write-Verbose -Message "VM $Name is does not have startup memory of $StartupMemoryMB"
                SetVMState -Name $Name -State Off
                Set-VM -Name $Name -MemoryStartupBytes $StartupMemoryMB*1MB 
                SetVMState -Name $Name -State Running -WaitForIP $WaitForIP
            }            
        }
    }
    # VM is not present, create one
    else
    {
        Write-Verbose -Message "VM $Name does not exists"
        if($Ensure -eq "Present")
        {
            Write-Verbose -Message "Creating VM $Name ..."
            $null = New-VM -Name $Name -VHDPath $VhDPath -SwitchName $SwitchName `
                            -MemoryStartupBytes ($StartUpMemoryMB*1MB) 
                
            SetVMState -Name $Name -State $State -WaitForIP $WaitForIP
            Write-Verbose -Message "VM $Name created and is $State"
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
	    [parameter(Mandatory)]
	    [ValidateNotNullOrEmpty()]
	    [String]$Name,

	    [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$VhDPath,

	    [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$SwitchName,

        [Boolean]$WaitForIP=$false,

        [ValidateNotNullOrEmpty()]
        [Int]$StartupMemoryMB,

        [ValidateSet("Running", "Paused", "Off")]
        [String]$State = "Running",

        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present"
    )

    # If the VhdPath doesn't ends with .vhd, add to it
    If(! $VhDPath.EndsWith(".vhd")){$VhDPath = $VhDPath+".vhd"}
    
    $result = $false

    try
    {
        $vmObj = Get-VM -Name $Name -ErrorAction Stop
        if( 
            ($vmObj.State -eq $State ) -and 
            (($vmObj.MemoryStartup/1MB) -eq $StartupMemoryMB) -and 
            ($vmObj.NetworkAdapters.SwitchName -eq $SwitchName)
        )
        {
            $result = ($Ensure -eq "Present")
        }
        else {$result = ($Ensure -eq "Absent")}
    }
    catch
    {
        $result = ($Ensure -eq 'Absent')
    }
    $result
}

# Helper function
function SetVMState
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [ValidateSet("Running","Paused","Off")]
        [String]$State,

        [Boolean]$WaitForIP
    )

    switch ($State)
    {
        'Running' {
            $oldState = (Get-VM -Name $Name).State
            # If VM is in paused state, use resume-vm to make it running
            if($oldState -eq "Paused"){Resume-VM -Name $Name}
            # If VM is Off, use start-vm to make it running
            elseif ($oldState -eq "Off"){Start-VM -Name $Name}
            
            if($WaitForIP)
            {
                while(!(Get-VMIPAddress $Name))
                {        
                    Write-Verbose "Waiting for IP Address ..."
                    Start-Sleep -Seconds 3;
                }
            }
        }
        'Paused' {Suspend-VM -Name $Name}
        'Off' {Stop-VM -Name $Name -Force -WarningAction SilentlyContinue}
    }
}