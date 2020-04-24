[CmdLetBinding()]
Param(
    [string][Parameter()]$OutPath
)

if(-not $OutPath)
{
    $OutPath = Resolve-Path "$PSScriptRoot/../temp/"
}


Install-Module -Name platyPS -Scope CurrentUser
Import-Module platyPS
Remove-Module Pinja.Azure.Alerts -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot/../src/Pinja.Azure.Alerts.psd1

New-MarkdownHelp -Module Pinja.Azure.Alerts -OutputFolder $OutPath -Force
