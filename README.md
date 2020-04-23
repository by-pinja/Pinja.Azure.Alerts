# azure-alerts

This is common baseline solution to apply good default alerts to any azure deployment with few simple commands. Alerts are applied based on resource types to all matching resources in resource group.

Goal is also to support more complicated alerts when needed by extending, overwriting existing alerts or by creting new ones. When none of these are applicaple you can still
use underlaying Az powershell to create that specific alert using same infrastructure like action groups.

## Requirements

- [Powershell](https://github.com/PowerShell/PowerShell)
- [Az module](https://github.com/Azure/azure-powershell)

## Applying good defaults

This is basic setup that cause alerts trigger in most common situations.

You have to define [receiver](https://docs.microsoft.com/en-us/powershell/module/az.monitor/new-azactiongroupreceiver) `ActionGroupReceiver`, which is part that sends alerts to channels like email or webhooks.

TODO: Example with alerta

```powershell
Install-Module Pinja.Azure.Alerts # TODO fix this name after this project is deployed to oneget.
Import-Module Pinja.Azure.Alerts

$receiver = New-AzActionGroupReceiver `
    -Name 'todo' `
    -WebhookReceiver `
    -ServiceUri "todo" `
    -UseCommonAlertSchema

Get-DefaultAlertRules | Apply-AlertRules.ps1 -ResourceGroup [Your resource group] -ActionGroupReceiver $hook
```

## Overwriting special cases

TODO

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
todo
```
