###########################################################################"
#
# NAME: Invoke-ADMTUserMigration.ps1
#
# AUTHOR: Jan Egil Ring
# EMAIL: jan.egil.ring@powershell.no
#
# COMMENT: This is an example on how to script the Active Directory Migration Tool (ADMT) using PowerShell.
#          It`s based on the sample templatescript.vbs which resides in the ADMT installation-directory.
#          NOTE: Since ADMT is a 32-bit application, this script must be run from Windows PowerShell (x86).
#          It also requires elevated privileges.
#
#          For more details, see the following blog-post: 
#          http://blog.powershell.no/2010/08/04/automate-active-directory-migration-tool-using-windows-powershell
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the creator, owner above has no warranty, obligations,
# or liability for such use.
#
# VERSION HISTORY:
# 1.0 04.08.2010 - Initial release
#
###########################################################################"

### BEGIN ADMT Scripting Constants ###

# PasswordOption constants

$admtComplexPassword                   = "&H0001"
$admtCopyPassword                      = "&H0002"
$admtDoNotUpdatePasswordsForExisting   = "&H0010"

# ConflictOptions constants

$admtIgnoreConflicting           = "&H0000"
$admtMergeConflicting            = "&H0001"
$admtRemoveExistingUserRights    = "&H0010"
$admtRemoveExistingMembers       = "&H0020"
$admtMoveMergedAccounts          = "&H0040"

# DisableOption constants

$admtLeaveSource        = "&H0000"
$admtDisableSource      = "&H0001"
$admtTargetSameAsSource = "&H0000"
$admtDisableTarget      = "&H0010"
$admtEnableTarget       = "&H0020"

# SourceExpiration constant

$admtNoExpiration = "-1"

# Translation Option

$admtTranslateReplace = "0"
$admtTranslateAdd     = "1"
$admtTranslateRemove  = "2"

# Report Type

$admtReportMigratedAccounts  = "0"
$admtReportMigratedComputers = "1"
$admtReportExpiredComputers  = "2"
$admtReportAccountReferences = "3"
$admtReportNameConflicts     = "4"

# Option constants

$admtNone     = "0"
$admtData     = "1"
$admtFile     = "2"
$admtDomain   = "3"
$admtRecurse           = "&H0100"
$admtFlattenHierarchy  = "&H0000"
$admtMaintainHierarchy = "&H0200"

# Event related constants

# Progress type
$admtProgressObjectMigration   = "0"
$admtProgressAgentDispatch     = "1"
$admtProgressAgentOperation    = "2"
$admtProgressMailboxMigration  = "3"

# Event type
$admtEventNone                         = "0"
$admtEventObjectInputPreprocessed      = "1"
$admtEventTaskStart                    = "2"
$admtEventTaskFinish                   = "3"
$admtEventObjectProcessed              = "4"
$admtEventGroupMembershipProcessed     = "5"
$admtEventAgentStatusUpdate          ="6"
$admtEventAgentNotStarted = "7"
$admtEventAgentFailedToStart = "8"
$admtEventAgentWaitingForReboot = "9"
$admtEventAgentRunning = "10"
$admtEventAgentCancelled = "11"
$admtEventAgentPassed = "12"
$admtEventAgentFailed = "13"
$admtEventAgentWaitingForRetry = "14"
$admtEventAgentSuccessful = "15"
$admtEventAgentCompletedWithWarnings = "16"
$admtEventAgentCompletedWithErrors = "17"
$admtEventTaskLogSaved = "18"

$admtAgentPreCheckPhase = "&H100"
$admtAgentAgentOperationPhase = "&H200"
$admtAgentPostCheckPhase = "&H300"

$admtAgentStatusMask = "&HFF"
$admtAgentPhaseMask = "&H300"

# Status type
$admtStatusSuccess   = "0"
$admtStatusWarnings  = "1"
$admtStatusErrors    = "2"

### END ADMT Scripting Constants ###

#Creates an instance of an ADMT migration object using the COM-object provided with ADMT
$Migration = New-Object -ComObject "ADMT.Migration"
$Migration.IntraForest = $false
$Migration.SourceDomain = "contoso-old.local"
$Migration.SourceDomainController = "dc01.contoso-old.local"
$Migration.SourceOU = "Europe/Norway/Oslo"
$Migration.TargetDomain = "contoso-new.local"
$Migration.TargetDomainController = "dc02.contoso-new.local"
$Migration.TargetOU = "Europe/Norway/Oslo"
$Migration.PasswordOption = $admtComplexPassword
$Migration.PasswordServer = "dc01.contoso-old.local"
$Migration.PasswordFile = "C:\WINDOWS\ADMT\Logs\Passwords.txt"
$Migration.ConflictOptions = $admtIgnoreConflicting
$Migration.UserPropertiesToExclude = ""
$Migration.InetOrgPersonPropertiesToExclude = ""
$Migration.GroupPropertiesToExclude = ""
$Migration.ComputerPropertiesToExclude = ""
$Migration.SystemPropertiesToExclude = ""
$Migration.PerformPreCheckOnly = $false
$Migration.AdmtEventLevel = $admtStatusWarnings
$Migration.CommandLine = $false

#Creates an user migration object
$UserMigration = $Migration.CreateUserMigration()
$UserMigration.DisableOption = $admtTargetSameAsSource
$UserMigration.SourceExpiration = $admtNoExpiration
$UserMigration.MigrateSIDs = $true
$UserMigration.TranslateRoamingProfile = $false
$UserMigration.UpdateUserRights = $false
$UserMigration.MigrateGroups = $false
$UserMigration.UpdatePreviouslyMigratedObjects = $false
$UserMigration.FixGroupMembership = $true
$UserMigration.MigrateServiceAccounts = $false

#Initiates user migration. Logs are written to C:\Windows\ADMT\Logs by default.
$UserMigration.Migrate($admtDomain,$null,$null)

#Creates a password migration object
$PasswordMigration = $Migration.CreatePasswordMigration()

#Initiates password migration. Logs are written to C:\Windows\ADMT\Logs by default.
$PasswordMigration.Migrate($admtDomain,$null,$null)