[CmdLetBinding()]
Param(
    [string][Parameter()]$OutPath
)

if(-not $OutPath)
{
    $OutPath = Resolve-Path "$PSScriptRoot/../temp/"
}


Remove-Module Pinja.Azure.Alerts
Import-Module $PSScriptRoot/../src/Pinja.Azure.Alerts.psd1

New-MarkdownHelp -Module Pinja.Azure.Alerts -OutputFolder $OutPath -Force
