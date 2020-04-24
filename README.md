# azure-alerts

[![Pinja.Azure.Alerts](https://img.shields.io/powershellgallery/v/Pinja.Azure.Alerts.svg?style=flat-square&label=Pinja.Azure.Alerts)](https://www.powershellgallery.com/packages/Pinja.Azure.Alerts/)

This is common baseline solution to apply good default alerts to any azure deployment with few simple commands. Alerts are applied based on resource types to all matching resources in resource group.

Goal is also to support more complicated alerts when needed by extending, overwriting existing alerts or by creting new ones. When none of these are applicaple you can still
use underlaying Az powershell to create that specific alert using same infrastructure like action groups.

## Requirements

- [Powershell](https://github.com/PowerShell/PowerShell)
- [Az module](https://github.com/Azure/azure-powershell)

## Applying good defaults

This is basic setup that cause alerts trigger in most common situations.

You have to define [receiver](https://docs.microsoft.com/en-us/powershell/module/az.monitor/new-azactiongroupreceiver) `ActionGroupReceiver`, which is part that sends alerts to channels like email or webhooks.

```powershell
Install-Module Pinja.Azure.Alerts
Import-Module Pinja.Azure.Alerts

$receiver = New-AzActionGroupReceiver `
    -Name 'alerta-webhook' `
    -WebhookReceiver `
    -ServiceUri "http://your.alerta.domain/webhooks/azuremonitor" `
    -UseCommonAlertSchema

Get-DefaultAlertRules | Set-AlertRules -ResourceGroup [Your resource group] -ActionGroupReceiver $receiver
```

Note that `Set-AlertRules` supports `-WhatIf` parameter for dry runs that makes developing alert rules much easier.

For full documentation see:

```powershell
Get-Help Set-AlertRules -Full
```

## Overwriting special cases

Its common that there is good baseline alert for type but there are exception that either requires addional documentation
or different limits.

Naming few:

- Additional fix or validation steps to documentation.
- Replace documentation with custom steps.
- Different configuration for criteria. For example maybe one of api will have problems if CPU goes over 50% istead of default provided.
- And so on...

### Documenting alerts

Idea is that with alert there is builtin documentation for each alert sent in description that contains information how to
validate and fix possible situation.

Fix steps are often common, like restarting or upscaling web application and this repository is maintaining common fix steps
for those situation.

Validation is usually defined by project as example it may require to login or test actual web application in user perspective
how it behaves after alert is triggered before further actions are done.

For this reason there is support to easily extend documentation for specific alerts of resource. As example if payment releated
api have increased error rate it is usually good routine to point to test payments instead of something else.

```powerhell
Get-DefaultAlertRules |
    New-AlertRuleOverwrite `
        -ResourceType "Microsoft.Web/Sites" `
        -Name "Few Server errors" `
        -FixSteps "https://youAdditionalSteps.com" `
        -ResourceFilter { $_.Name -like "*my-web-api*" } `
        -FixStepsLocation Before
```

Adds additional documentation to alert rule `Microsoft.Web/Sites` > `Few Server errors` on web site where resource name matches `*my-web-api*`.

### Others

See `New-AlertRuleOverwrite` help for full documentation how to override defaults for specific resources.

```powershell
Get-Help New-AlertRuleOverwrite -Full
```
