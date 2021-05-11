# Run the demos from elevated PowerShell/ISE 
# Set-ExecutionPolicy to run .ps1 files (Set-ExecutionPolicy RemoteSigned -Force)
# On client (windows 8.1): Turn on WSMan (Enable-PSRemoting -force)
# Set WSMan trusted host to * (Set-Item WSMan:\localhost\Client\TrustedHosts * -Force)

# Copy applicable custom DSC resources (in \PreReq\Resources folder) to $pshome\Modules on the nodes
#   * On the machine where configurations are authored, copy all the custom DSC resources
#   * On the WebServers, copy Demo_Computer and Demo_IISWebsite resources
#   * On the Domain controller, copy Demo_Computer, Demo_DCPromo, Demo_DHCPOption, Demo_DHCPScope, Demo_DHCPServerinDC resources
#   * On the Hyper-V host, copy Demo_OptionalFeature, Demo_VHD, Demo_VM, Demo_VMSwitch resources

# Copy Get-VMIP and WebVM modules (in \PreReq folder) to PowerShell module path ($env:PSModulePath)
# Copy website content folder ( \PreReq\BakeryWebsite folder) to webservers C: drive

# For Pull Server setup
#    * Currently, works only on Full-Server SKU
#    * Invoke the InstallPullServerConfig.ps1 -DSCServiceSetup (in \PullServer\Setup\Scripts folder) from elevated prompt on Pull Server
#    * On successful completion of above script, copy the PullServer content (in \PullServer\Content folder) to C:\ProgramData\PSDSCPullServer folder of the Pull Server node