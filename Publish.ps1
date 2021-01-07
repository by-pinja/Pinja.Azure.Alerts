[CmdletBinding()]
Param(
    [string][Parameter(Mandatory)]$Version,
    [string][Parameter(Mandatory)]$NuGetApiKey
)

Update-ModuleManifest -Path $PSScriptRoot/Pinja.Azure.Alerts/Pinja.Azure.Alerts.psd1 -ModuleVersion $Version
Publish-Module -Path $PSScriptRoot/Pinja.Azure.Alerts -NuGetApiKey $NuGetApiKey -WhatIf