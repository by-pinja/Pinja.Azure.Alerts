[CmdLetBinding()]
Param([string]$OutPath)

. $PSScriptRoot/../src/Get-DefaultAlertRules.ps1

$asText = Get-DefaultAlertRules | &"$PSScriptRoot/ConvertTo-Markdown.ps1"

$asText | Set-Content -Path $OutPath