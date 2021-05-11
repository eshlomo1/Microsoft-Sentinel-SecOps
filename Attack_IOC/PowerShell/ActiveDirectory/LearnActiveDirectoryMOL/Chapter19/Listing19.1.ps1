<#
 Code listings from:
  Active Directory Management in a Month of Lunches
  Chapter 19

 All code supplied "as is" as an example to illustrate the text. No guarantees or warranties are supplied with this code.
 It is YOUR responsibilty to test if for suitability in YOUR environment.
 The comments match the section headings in the chapter
#>
Get-ADComputer -SearchBase "OU=Domain Controllers,DC=Manticore,DC=org"  -Filter * |                         
foreach {
  Get-ADDomainController -Identity $_.DNSHostName     
 } | 
 where Site -eq 'Default-First-Site-Name' |                     
 foreach {
    if (Test-Connection -ComputerName $psitem.Name -Quiet -Count 1){
      Get-ADReplicationFailure -Target DC01                    
    }
    else {
      Write-Warning -Message "Cannot contact $($psitem.Name)"       
    }
 } 
