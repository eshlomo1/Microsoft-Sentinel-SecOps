<#

.Purpose 
    Elli Shlomo Managed Azure Sentinel Onboarding 

.Description
    The following PowerShell script will deploy and configure Azure Lighthouse and configure the relevant requirements on the Customer Subscription 

.OnabordingLevel

    Azure Resource Level - Resource Group Level
    Advanced Level - Read permissions for Azure Sentinel Workspace /  Read permissions for Azure Security Security 
    Permissions Level
        Azure Sentinel Contributor for Managers
        Azure Sentinel Responder for TIER 3 Analyst 
        Azure Sentinel Reader for TIER 2 Analyst
        Security Reader for Managers
        Logic App Operator

.Artifacts
    -Resource Group Level
    -Install Az.Resource Module 
    -Register Azure Resource Provider
    -Delegate Azure Lighthouse

#>

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Verbose
 
### Install Az Module
Install-Module Az.Resources -Scope CurrentUser -AllowClobber -Force
 
### Interactive login to Azure Subscription 
Login-AzAccount # The browser will popup for creds

# Selected Subscription
Select-AzSubscription -SubscriptionId "put your sub id"

### Register for Azure Resource Providers for Azure and Security 

Register-AzResourceProvider -ProviderNamespace Microsoft.ManagedServices    # Azure Lighthouse
Register-AzResourceProvider -ProviderNamespace Microsoft.SecurityInsights   # Azure Sentinel
Register-AzResourceProvider -ProviderNamespace Microsoft.Notebooks          # Azure Notebooks
Register-AzResourceProvider -ProviderNamespaceMicrosoft.OperationalInsights 

### Run Azure Lighthouse Delegation

New-AzDeployment -Name "Namr of Managed Sentinel" `
 -Location "West Europe" `
  -TemplateFile 'change path - \rgDelegatedResourceManagement.json' `
   -TemplateParameterFile 'change - path \rgDelegatedResourceManagement.parameters.json' `
   -Verbose