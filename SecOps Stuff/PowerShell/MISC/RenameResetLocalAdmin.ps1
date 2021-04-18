#-------Enable, Rename, & Reset Local Administrator Password-------#
####################################################################

#Get Service Tag
$servicetag = (gwmi win32_bios).SerialNumber

#Rename Local Admin Account
$admin=[adsi]"WinNT://./Administrator,user" 
$admin.psbase.rename("Ron.Johnson")

#Enables & Sets User Password
invoke-command { net user Ron.Johnson Adm.$servicetag /active:Yes }

########################################################################
#----------------------Creator - Joshua.Duffney------------------------#
#----------------------        Sources         ------------------------#
#Sources
#http://myitforum.com/cs2/blogs/yli628/archive/2010/05/19/mdt-create-a-task-sequence-using-powershell-to-rename-local-administrator-account.aspx
#http://jdhitsolutions.com/blog/2014/04/set-local-user-account-with-powershell/
#https://community.spiceworks.com/topic/493143-trimming-variables-with-powershell?page=1#entry-3306064
#----------------------      Notes              ------------------------#
#must run the following command in SCCM for the script to run
#Powershell.exe -command "Set-ExecutionPolicy RemoteSigned;
