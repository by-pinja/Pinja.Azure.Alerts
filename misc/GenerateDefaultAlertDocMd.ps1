[CmdLetBinding()]
Param([string]$OutPath)

. $PSScriptRoot/../src/Get-DefaultAlertRules.ps1

$parentFolder = (Split-Path -Path $OutPath -Parent)

if(-not (Test-Path $parentFolder))
{
    New-Item -ItemType Directory $parentFolder -Force
}

$asText = Get-DefaultAlertRules | &"$PSScriptRoot/ConvertTo-Markdown.ps1"

$asText | Set-Content -Path $OutPath