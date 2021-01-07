[CmdLetBinding()]
Param([string]$OutPath)

. $PSScriptRoot/../Pinja.Azure.Alerts/Get-DefaultAlertRules.ps1

$parentFolder = (Split-Path -Path $OutPath -Parent)

if(-not (Test-Path $parentFolder))
{
    New-Item -ItemType Directory $parentFolder -Force
}

$asText = "
# Default alerts
These alerts are tried used as good baseline default for all matching resources.
"

foreach($rule in  Get-DefaultAlertRules)
{
    $asText += @"
| Name                 | Value |
|----------------------|-------|
| Name                 | $($rule.Name)                      |
| ResourceType         | $($rule.ResourceType)              |
| Description          | $($rule.Description)               |
| AlertValidationSteps | $($rule.AlertValidationSteps)      |
| AlertFixSteps        | $($rule.AlertFixSteps)             |
| Criteria             | $((($rule.Criteria).ToString() -replace '\|','' -replace "`t|`n|`r","").Trim())  |
| Severity     | $($rule.Severity)          |


"@

}

$asText | Set-Content -Path $OutPath