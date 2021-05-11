#Creating Hash table
  $hash=@{
                    Computername=$cs.Name
                    Workgroup=$cs.WorkGroup
                    AdminPassword=$aps
                    Model=$cs.Model
                    Manufacturer=$cs.Manufacturer
                }
#Adding lines to hash table
$os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer
$hash.Add("Version",$os.Version)
$hash.Add("ServicePackMajorVersion",$os.ServicePackMajorVersion)

#add values to properties that dont exist
$splat = @{Properties=('Managedby','whencreated');Identity='testgroup';server='domain.com'}
if(!$splat.Properties.Contains('member')){$splat.Properties = $splat.Properties += 'member'}
