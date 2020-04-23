# azure-alerts

This is common baseline solution to apply good default alerts to any azure deployment with few simple commands. Alerts are applied based on resource types to all matching resources in resource group.

Goal is also to support more complicated alerts when needed by extending or overwriting default ones.

Idea is to create versioned default alert setup that is easy to use and update in multiple projects.

## Requirements

- [Powershell](https://github.com/PowerShell/PowerShell)
- [Az module](https://github.com/Azure/azure-powershell)

## Applying good defaults

This is basic setup that cause alerts trigger in most common situations.

You have to define `ActionGroupReceiver`, which is part that sends alerts to channels like email or webhooks.

TODO: Example with alerta

```powershell
Install-Module todo # TODO fix this name after this project is deployed to oneget.
Import-Module todo

$receiver = New-AzActionGroupReceiver `
    -Name 'todo' `
    -WebhookReceiver `
    -ServiceUri "todo" `
    -UseCommonAlertSchema

Get-DefaultAlertRules | Apply-AlertRules.ps1 -ResourceGroup [Your resource group] -ActionGroupReceiver $hook
```

## Overwriting special cases

TODO