param (
    [string]$PolicyFile,
    [string]$OutputFile
)

function Get-SectionTitle([string]$Title) {
    return "`n---`n`n### $Title`n"
}

function Get-SubsectionTitle([string]$Title) {
    return "`n#### $Title`n"
}

function FormatDefinition([string]$Definition) {
    $splitDefinition = $Definition.Split('/')
    $displayName = $splitDefinition[-1]

    if ($splitDefinition[1] -eq "providers" -and $splitDefinition[2] -eq "Microsoft.Management") {
        $scope = "/managementGroups/" + $splitDefinition[4]
    } elseif ($splitDefinition[1] -eq "subscriptions") {
        $scope = "/subscriptions/" + $splitDefinition[2]
    } else {
        $scope = '/' + ($splitDefinition[1..($splitDefinition.Length - 4)] -join '/')
    }

    return "'$displayName' at $scope"
}

$json = Get-Content $PolicyFile -Raw | ConvertFrom-Json
$policyDefinitions = $json.policyDefinitions
$policySetDefinitions = $json.policySetDefinitions
$policyAssignments = $json.assignments

$newPolicyDefinitions = $policyDefinitions.new.PSObject.Properties | ForEach-Object { $_.Value.displayName }
$deletedPolicyDefinitions = $policyDefinitions.delete.PSObject.Properties | ForEach-Object { $_.Value.DisplayName }
$updatedPolicyDefinitions = $policyDefinitions.update.PSObject.Properties | ForEach-Object { $_.Value.displayName }
$replacedPolicyDefinitions = $policyDefinitions.replace.PSObject.Properties | ForEach-Object { $_.Value.displayName }

$newPolicySetDefinitions = $policySetDefinitions.new.PSObject.Properties | ForEach-Object { $_.Value.displayName }
$deletedPolicySetDefinitions = $policySetDefinitions.delete.PSObject.Properties | ForEach-Object { $_.Value.displayName }
$updatedPolicySetDefinitions = $policySetDefinitions.update.PSObject.Properties | ForEach-Object { $_.Value.displayName }
$replacedPolicySetDefinitions = $policySetDefinitions.replace.PSObject.Properties | ForEach-Object { $_.Value.displayName }

$newAssignments = $policyAssignments.new.PSObject.Properties | ForEach-Object { $_.Value.id }
$deletedAssignments = $policyAssignments.delete.PSObject.Properties | ForEach-Object { $_.Value.id }
$updatedAssignments = $policyAssignments.update.PSObject.Properties | ForEach-Object { $_.Value.id }
$replacedAssignments = $policyAssignments.replace.PSObject.Properties | ForEach-Object { $_.Value.id }

$sections = @()

$sections += "# Policy Update Report"
$sections += Get-SectionTitle "Policy Definitions"
$sections += @"
- Number of Changes: $($policyDefinitions.numberOfChanges)
- Number Unchanged: $($policyDefinitions.numberUnchanged)
"@

if ($newPolicyDefinitions) {
    $sections += Get-SubsectionTitle "New Policy Definitions ($($newPolicyDefinitions.count))"
    $sections += ($newPolicyDefinitions -join "`n") + "`n"
}

if ($deletedPolicyDefinitions) {
    $sections += Get-SubsectionTitle "Deleted Policy Definitions ($($deletedPolicyDefinitions.count))"
    $sections += ($deletedPolicyDefinitions -join "`n") + "`n"
}

if ($updatedPolicyDefinitions) {
    $sections += Get-SubsectionTitle "Updated Policy Definitions ($($updatedPolicyDefinitions.count))"
    $sections += ($updatedPolicyDefinitions -join "`n") + "`n"
}

if ($replacedPolicyDefinitions) {
    $sections += Get-SubsectionTitle "Replaced Policy Definitions ($($replacedPolicyDefinitions.count))"
    $sections += ($replacedPolicyDefinitions -join "`n") + "`n"
}

$sections += Get-SectionTitle "Policy Set Definitions"
$sections += @"
- Number of Changes: $($policySetDefinitions.numberOfChanges)
- Number Unchanged: $($policySetDefinitions.numberUnchanged)
"@

if ($newPolicySetDefinitions) {
    $sections += Get-SubsectionTitle "New Policy Set Definitions ($($newPolicySetDefinitions.count))"
    $sections += ($newPolicySetDefinitions -join "`n") + "`n"
}

if ($deletedPolicySetDefinitions) {
    $sections += Get-SubsectionTitle "Deleted Policy Set Definitions ($($deletedPolicySetDefinitions.count))"
    $sections += ($deletedPolicySetDefinitions -join "`n") + "`n"
}

if ($updatedPolicySetDefinitions) {
    $sections += Get-SubsectionTitle "Updated Policy Set Definitions ($($updatedPolicySetDefinitions.count))"
    $sections += ($updatedPolicySetDefinitions -join "`n") + "`n"
}

if ($replacedPolicySetDefinitions) {
    $sections += Get-SubsectionTitle "Replaced Policy Set Definitions ($($replacedPolicySetDefinitions.count))"
    $sections += ($replacedPolicySetDefinitions -join "`n") + "`n"
}

$sections += Get-SectionTitle "Assignments"
$sections += @"
- Number of Changes: $($policyAssignments.numberOfChanges)
- Number Unchanged: $($policyAssignments.numberUnchanged)
"@

if ($newAssignments) {
    $sections += Get-SubsectionTitle "New Assignments ($($newAssignments.count))"
    $sections += ($newAssignments | ForEach-Object { FormatDefinition $_ }) -join "`n" + "`n"
}

if ($deletedAssignments) {
    $sections += Get-SubsectionTitle "Deleted Assignments ($($deletedAssignments.count))"
    $sections += ($deletedAssignments | ForEach-Object { FormatDefinition $_ }) -join "`n" + "`n"
}

if ($updatedAssignments) {
    $sections += Get-SubsectionTitle "Updated Assignments ($($updatedAssignments.count))"
    $sections += ($updatedAssignments -join "`n") + "`n"
}

if ($replacedAssignments) {
    $sections += Get-SubsectionTitle "Replaced Assignments ($($replacedAssignments.count))"
    $sections += ($replacedAssignments -join "`n") + "`n"
}

$output = $sections -join "`n"
$output | Out-File -FilePath $OutputFile
   
