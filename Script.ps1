
Get-ChildItem $PSScriptRoot/Pinja.Azure.Alerts/*.ps1 | foreach { . $_.FullName }

$receiver = New-AzActionGroupReceiver `
    -Name 'FunctionAppWebHook' `
    -WebhookReceiver `
    -ServiceUri "https://adsasdfkfadsoafsdkfadsoodfsakdsfaoadfs.fi" `
    -UseCommonAlertSchema

Get-DefaultAlertRules | Set-AlertRules -ResourceGroup 'foo' -ActionGroupReceiver $receiver

# $alertRules = .\Get-DefaultAlertRules.ps1 | .\New-AlertRuleOverwrite.ps1 -ResourceType "Microsoft.Web/Sites" -Name "Few Server errors" -ResourceFilter { $_.Name -like "*testing2312313"} -FixSteps "https://newfoo.fi" -FixStepsLocation Before
# # | .\New-AlertRule.ps1 -ResourceType "Microsoft.Web/Sites" -Name "foo" -Description "foo" -Severity Critical -Criteria {} -WindowSize (new-timespan -Hours 1)
# .\Apply-AlertRules.ps1 -ResourceGroup pekantesti1 -AlertRules $alertRules -ActionGroupReceiver $webHookReceiver -WhatIf