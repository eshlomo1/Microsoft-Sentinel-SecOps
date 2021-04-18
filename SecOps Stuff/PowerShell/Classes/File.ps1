#Figure out enums
Class File {

#constructor
File($Name,$Path){
    $this.Name = $Name
    $this.Path = $Path
}

#properties
[string]$Name
[string]$Path
[string]$Content

#method
[void] Create() {
    New-Item -Name $this.Name -Path $this.Path
}

}

#New-Object -TypeName File -ArgumentList 'ClassTest','C:\temp'
$File = [File]::New('PSClassTest','c:\temp')
$File.Create()

Get-ChildItem -Path c:\temp