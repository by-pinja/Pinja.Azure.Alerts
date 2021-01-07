function New-AlertRule {
    <#
    .SYNOPSIS
    Create new alert rule

    .DESCRIPTION
    Create new alert rule. Simplifies custom alert creation by giving defaults for non mandatory values
    and validations for allowed values.

    .PARAMETER ResourceType
    Type of resource alert is applied, for example 'Microsoft.Web/Sites'

    .PARAMETER Name
    Name of alert. This is shown on alert page and is used to check uniquenes. Alert with same name will be overwritten.

    .PARAMETER Severity
    Severity of alert.

    .PARAMETER Criteria
    Scriptblock that defines alert criteria object. See documentation of New-AzMetricAlertRuleV2Criteria.
    Scriptblock is used so you can use targeted resource from pipeline variable ($_) for creating criteria with specific names
    or parameters based on resource it is applied.

    .PARAMETER Description
    Description of alert what happened and possible short description what this means in system perspective.

    .PARAMETER AlertValidationSteps
    Additional information (runbook / validation part) how receiver of alert can check that is system working or not. Usually contains array of links
    for documents how to validate system is working properly or not.

    .PARAMETER AlertFixSteps
    Additional information (runbook / fix part) how receiver can fix issue after its validated that it isn't working properly. Usually contains array of links
    for documents how to attempt fix specific problematic resource.

    .PARAMETER WindowSize
    How wide window is used to calculate criteria.

    .PARAMETER Frequency
    How ofter defined window for criteria is checked.

    .PARAMETER InputObject
    Supports adding new alert to existing alerts with pipeline syntax.

    .EXAMPLE
    New-AlertRule `
        -ResourceType 'Microsoft.Web/Sites' `
        -Name "my-alert-1" `
        -Severity Critical `
        -Criteria { New-AzMetricAlertRuleV2Criteria -MetricName 'Http5xx' -TimeAggregation Total -Operator GreaterThan -Threshold 5 } `
        -WindowSize (New-TimeSpan -Minutes 5) `
        -Frequency (New-TimeSpan -Minutes 5)

    .EXAMPLE
    $alertsWithAdditional = Get-DefaultAlertRules |
        New-AlertRule `
            -ResourceType 'Microsoft.Web/Sites' `
            -Name "my-alert-1" `
            -Severity Critical `
            -Criteria { New-AzMetricAlertRuleV2Criteria -MetricName 'Http5xx' -TimeAggregation Total -Operator GreaterThan -Threshold 5 } `
            -WindowSize (New-TimeSpan -Minutes 5) `
            -Frequency (New-TimeSpan -Minutes 5)

    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    Param(
        [string][Parameter(Mandatory)]$ResourceType,
        [string][Parameter(Mandatory)]$Name,
        [ValidateSet("Critical", "Error", "Warning", "Information")]
        [string][Parameter(Mandatory)]$Severity,
        [ScriptBlock][Parameter(Mandatory)]$Criteria,
        [string][Parameter()]$Description = "",
        [string[]][Parameter()]$AlertValidationSteps = @(),
        [string[]][Parameter()]$AlertFixSteps = @(),
        [timespan][Parameter()]$WindowSize,
        [timespan][Parameter()]$Frequency,
        [PsCustomObject[]][Parameter(ValueFromPipeline)]$InputObject
    )

    PROCESS {
        foreach ($original in $InputObject) {
            return $original
        }
    }
    END {
        [PSCustomObject]@{
            ResourceType         = $ResourceType
            Name                 = $Name
            Description          = $Description
            AlertValidationSteps = $AlertValidationSteps
            AlertFixSteps        = $AlertFixSteps
            Criteria             = $Criteria
            Severity             = $Severity
            WindowSize           = if ($WindowSize) { $WindowSize } else { New-TimeSpan -Minutes 5 }
            Frequency            = if ($Frequency) { $Frequency } else { New-TimeSpan -Minutes 5 }
        }
    }
}