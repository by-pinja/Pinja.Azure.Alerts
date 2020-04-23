#Requires -Modules Az.Resources

. $PSScriptRoot/Get-DefaultAlertRules.ps1
. $PSScriptRoot/New-AlertRule.ps1
. $PSScriptRoot/New-AlertRuleOverwrite.ps1
. $PSScriptRoot/Set-AlertRules.ps1

Export-ModuleMember `
    Get-DefaultAlertRules, `
    New-AlertRule, `
    New-AlertRuleOverwrite, `
    Set-AlertRules