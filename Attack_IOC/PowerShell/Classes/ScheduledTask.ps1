class ScheduledTask {
    [string]$TaskName
    [CimInstance]$Action
    [CimInstance]$Settings
    [CimInstance]$Task

    ScheduledTask([string]$TaskName,[string]$Execute) {
        $this.TaskName = $TaskName
        $this.Action = New-ScheduledTaskAction -Execute $Execute
        $this.Settings = New-ScheduledTaskSettingsSet
    }

    ScheduledTask([string]$TaskName,[string]$Execute) {
        $this.TaskName = $TaskName
        $this.Action = New-ScheduledTaskAction -Execute $Execute
        $this.Settings = New-ScheduledTaskSettingsSet
    }      

    ScheduledTask([string]$TaskName,[string]$Execute,[string]$Arguement) {
        $this.TaskName = $TaskName
        $this.Action = New-ScheduledTaskAction -Execute $Execute -Argument $Arguement
        $this.Settings = New-ScheduledTaskSettingsSet
    }    

    [void]SetTask(){
        $this.Task = New-ScheduledTask -Settings $this.Settings -Action $this.Action
    }

    [void]Register(){
        Register-ScheduledTask -TaskName $this.TaskName -InputObject $this.task
    }
}

$NewTask = [ScheduledTask]::New('T6','Taskmgr.exe','-NonInteractive -NoLogo')
$NewTask.SetTask()