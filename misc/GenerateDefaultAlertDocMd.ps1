[CmdLetBinding()]
Param([string]$OutPath)

. $PSScriptRoot/../Get-DefaultAlertRules.ps1

$asText = Get-DefaultAlertRules | &"$PSScriptRoot/ConvertTo-Markdown.ps1"

$asText | Set-Content -Path $OutPath