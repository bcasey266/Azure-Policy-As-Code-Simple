# Definitions and Global Settings

## Table of Contents

- [Overview](#overview)
- [Global Settings](#global-settings)
  - [managedIdentityLocation](#managedidentitylocation)
  - [globalNotScopes](#globalnotscopes)
  - [pacEnvironments](#pacenvironments)

## Overview

Within this folder contains the Global Settings file (global-settings.jsonc) and 4 folders containing the different sections of Azure Policy. The Global Settings is detailed further down on this page. The four folders are:

| Name                                                  | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [**Assignments**](/Definitions/policyAssignments/)    | An assignment is a policy definition or initiative that has been assigned to a specific scope. This scope could range from a management group to an individual resource. The term scope refers to all the resources, resource groups, subscriptions, or management groups that the definition is assigned to. Assignments are inherited by all child resources. This design means that a definition applied to a resource group is also applied to resources in that resource group. However, you can exclude a subscope from the assignment. <br /><br />Policy assignments always use the latest state of their assigned definition or initiative when evaluating resources. If a policy definition that is already assigned is changed all existing assignments of that definition will use the updated logic when evaluating. [^assign] |
| [**Exemptions**](/Definitions/policyExemptions/)      | (Future Implementation) The Azure Policy exemptions feature is used to exempt a resource hierarchy or an individual resource from evaluation of initiatives or definitions. [^exempt]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| [**Initiatives**](/Definitions/policySetDefinitions/) | An initiative definition is a collection of policy definitions that are tailored toward achieving a singular overarching goal. Initiative definitions simplify managing and assigning policy definitions. They simplify by grouping a set of policies as one single item. [^init]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| [**Policies**](/Definitions/policyDefinitions/)       | The journey of creating and implementing a policy in Azure Policy begins with creating a policy definition. Every policy definition has conditions under which it's enforced. And, it has a defined effect that takes place if the conditions are met. [^def]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |

## Global Settings

The file global-settings.jsonc defines the environments to deploy. The rationale for having so many is to allow targeted deployments. New/updated policies can be rolled out at lower environments first before going to higher environments. In addition, if a need arose in the future to have additional policies that only apply to 1 environment, this can support that.

The rest of this page breaks down the different parts of the global-settings.jsonc file.

</br>

### pacOwnerId

pacOwnerId is required for desired state handling to distinguish Policy resources deployed via this EPAC repo, legacy technology, another EPAC repo, or another Policy as Code solution.

### managedIdentityLocation

```json
    "managedIdentityLocation": {
        "*": "centralus"
    },
```

Policies with `Modify` and `DeployIfNotExists` effects require a Managed Identity for the remediation task. This section defines the location of the managed identity. It is often created in the tenant's primary location. This location can be overridden in the Policy Assignment files. The star in the example matches all `PacEnvironmentSelector` values.

<br/>

### globalNotScopes

```json
    "globalNotScopes": {
        "*": [
            "/resourceGroupPatterns/synapseworkspace-managedrg-*",
            "/resourceGroupPatterns/managed-rg-*",
            "/resourceGroupPatterns/databricks-*",
            "/resourceGroupPatterns/DefaultResourceGroup*",
            "/resourceGroupPatterns/NetworkWatcherRG",
            "/resourceGroupPatterns/LogAnalyticsDefault*",
            "/resourceGroupPatterns/cloud-shell-storage*"
        ]
    },
```

Resource Group patterns allow us to exclude "special" managed Resource Groups. The exclusion is not dynamic. It is calculated when the deployment scripts execute.

The arrays can have the following entries:

| Scope type              | Example                                                                                                                                                                                                                                                                     |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `managementGroups`      | "/providers/Microsoft.Management/managementGroups/myManagementGroupId"                                                                                                                                                                                                      |
| `subscriptions`         | "/subscriptions/00000000-0000-0000-000000000000"                                                                                                                                                                                                                            |
| `resourceGroups`        | "/subscriptions/00000000-0000-0000-000000000000/resourceGroups/myResourceGroup"                                                                                                                                                                                             |
| `resourceGroupPatterns` | No wild card or single \* wild card at beginning or end of name or both; wild cards in the middle are invalid: <br/> "/resourceGroupPatterns/name" <br/> "/resourceGroupPatterns/name\*" <br/> "/resourceGroupPatterns/\*name" <br/> "/resourceGroupPatterns/\*name\*"<br/> |

</br>

### pacEnvironments

pacEnvironments define the environment controlled by Policy as Code as defined at the top of this page

Each entry in the array defines one of the environments:

| Element                  | Description                                                                                                                                                                       |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pacSelector`            | Matches entry to `PacEnvironmentSelector`. A star is not valid.                                                                                                                   |
| `cloud`                  | Azure environment. Examples: `"AzureCloud"`, `"AzureUSGovernment"`, `"AzureGermanCloud"`. Defaults to `"AzureCloud"` with a warning                                               |
| `tenantId`               | Azure Tenant Id                                                                                                                                                                   |
| `rootDefinitionScope `   | the deployment destination for the Policies and Policy Sets to be used in assignments later. Policy Assignments can only defined at this root scope and child scopes (recursive). |
| `Optional: desiredState` | This element is used to set which desired state is used within this environment. This should be set to "full" and include Resource Groups                                         |

<br/>

## References

[^assign]: https://learn.microsoft.com/en-us/azure/governance/policy/overview#assignments
[^exempt]: https://learn.microsoft.com/en-us/azure/governance/policy/concepts/
[^init]: https://learn.microsoft.com/en-us/azure/governance/policy/overview#initiative-definition
[^def]: https://learn.microsoft.com/en-us/azure/governance/policy/overview#policy-definition
