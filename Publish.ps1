[CmdletBinding()]
Param(
    [string][Parameter(Mandatory)]$NuGetApiKey
)

if($env:GITHUB_REF) {
    $version = $env:GITHUB_REF -split "/" | select-object -last 1
    Write-Host "Found github ref, parsed version $version and updating it to module"
    Update-ModuleManifest -Path $PSScriptRoot/Pinja.Azure.Alerts/Pinja.Azure.Alerts.psd1 -ModuleVersion $Version
}

Publish-Module -Path $PSScriptRoot/Pinja.Azure.Alerts -NuGetApiKey $NuGetApiKey -WhatIf