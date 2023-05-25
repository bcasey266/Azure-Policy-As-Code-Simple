#Connect to Azure with an account/SPN that has Applications Read.Write
#Connect-AzAccount

### These values can be changed but recommended to stay as is
$Issuer = "https://token.actions.githubusercontent.com"
$Audience = "api://AzureADTokenExchange"
###

### GitHub Repo Settings
# The name of the GitHub Org and Repo
$Org = ""
$Repo = ""

# Options are "environment", "ref:refs/heads", "pull_request", "ref:refs/tags"
$Type = "environment"

# This is the name of the type above.  Example: Name of the environment
$TypeName = "dev"

$SubjectIdentifier = "repo:$Org/$($Repo):$($Type):$TypeName"
# The name/label that is used for this federation credential
$CredName = "GitHubActions-$TypeName"

# Service Principal Object ID (Not Application ID)
$ServicePrincipal = Get-AzADApplication -ApplicationId ""
$SPNObjectID = $ServicePrincipal.Id

New-AzADAppFederatedCredential -ApplicationObjectId $SPNObjectID -Audience $Audience -Issuer $Issuer -Name $CredName -Subject $SubjectIdentifier