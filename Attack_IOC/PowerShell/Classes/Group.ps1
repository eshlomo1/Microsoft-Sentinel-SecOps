class Group {
    [string]$Name
    [string]$Manager
    [string]$Members
    [string]$Domain

    Group () {}

    Group ([string]$Name) {
        $this.Name = $Name
    }

    [void]GetManager(){
         $this.Manager = (Get-ADGroup -Identity $this.Name -Properties Managedby).Managedby
         $this.Manager = $this.Manager -replace "(CN=)(.*?),.*",'$2'
    }

    [void]GetMembers(){
        $this.Members = (Get-NestedGroupMember -Group $this.Name).samaccountname
    }

    [void]GetDomain(){
        $this.Domain = (Get-ADGroup -Identity $this.Name -Properties CanonicalName).CanonicalName
        $this.Domain = ($this.Domain -split "/")[0]
    }

    [void]GetGroup(){
         $this.Manager = (Get-ADGroup -Identity $this.Name -Properties Managedby).Managedby
         $this.Manager = $this.Manager -replace "(CN=)(.*?),.*",'$2'
         $this.Members = (Get-NestedGroupMember -Group $this.Name).samaccountname
         $this.Domain = (Get-ADGroup -Identity $this.Name -Properties CanonicalName).CanonicalName
         $this.Domain = ($this.Domain -split "/")[0]             
    }

}

$Group = [Group]::New('testgroup')
$Group.GetManager()
$Group.GetMembers()
$Group.GetDomain()