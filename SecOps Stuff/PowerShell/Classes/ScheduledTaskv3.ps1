class ScheduledTask {
    [string]$TaskName
    [ciminstance]$TaskInstance

    ScheduledTask(){}
    
    ScheduledTask([string]$TaskName) {
        $this.TaskName = $TaskName
    }
    
    ScheduledTask([string]$TaskName,[CimInstance]$TaskInstance) {
        $this.TaskName = $TaskName
        $this.TaskInstance = $TaskInstance
    }       

    [void]Register(){
        Register-ScheduledTask -TaskName $this.TaskName -InputObject $this.TaskInstance
    }
}

Class Action : ScheduledTask {
    [string]$Execute
    [string]$Arguement
    [string]$WorkingDirectory

}

Class Settings : ScheduledTask {
    [CimInstance]$SettingsInstance

    Settings() {
        $this.SettingsInstance = New-ScheduledTaskSettingsSet
    }

    Settings([bool]$DontStopOnIdleEnd) {
        $this.SettingsInstance = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd
    }       
}

Class Task : ScheduledTask {
    [CimInstance]$TaskInstance

    Task([CimInstance]$Actions,[CimInstance]$Settings) {
        $this.TaskInstance = New-ScheduledTask -Settings $Settings -Action $Actions
    }  
}

# $Action = [Action]::new('powershell.exe','-nologon','C:\scripts')
# $Settings = [Settings]::new($true)
# $Task = [Task]::New($Action.ActionInstance,$Settings.SettingsInstance)
# $ScheduledTask = [ScheduledTask]::new('T1',$Task.TaskInstance)
# $ScheduledTask.Register()

$Action = [Action]::new()
$Action.Execute = 'powershell.exe';$Action.Arguement = '-nologon';$Action.WorkingDirectory = 'c:\scripts'