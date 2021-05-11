# ---------------------------------------------------
# Version: 2.0
# Author: Joshua Duffney
# Date: 05/11/2014
# Description: Read a text file with a list of computer names and then disables them.
# Comments: Refer to ApplicationCreation.csv in the repo to complete the script.
# ---------------------------------------------------

Function DisableADComputer {

Param(
    [string]$File
)

Import-Module activedirectory

ForEach ($Computer in (Get-Content $File)){
    Set-ADComputer -Identity $Computer -Enabled $false
    Write-host "$Computer has been disabled"
}

}

DisableADComputer -File "C:\Scripts\DisableComputerList.txt"
