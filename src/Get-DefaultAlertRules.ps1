function Get-DefaultAlertRules {
    <#
    .SYNOPSIS
    Provide good default alert rules for environments.

    .DESCRIPTION
    Provide good default alert rules for environments. This will evolve over time to match future needs and upcoming resource types.

    This method works as entrypoint to create more specific alerting setup when needed.

    .EXAMPLE
    Get-DefaultAlertRules

    Returns current well known setup of alert defaults.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    Param()

    @(
        [PSCustomObject]@{
            ResourceType         = 'Microsoft.Web/Sites'
            # Filter is expression that matches resource is it applicaple or not.
            # This can be used to extend alerts to specific resource instead of all instances of one type.
            Name                 = 'Few Server errors'
            Description          = 'Too many server errors!'
            AlertValidationSteps = @("https://todo/Insights+-+Server+errors")
            AlertFixSteps        = @("https://github.com/by-pinja/Pinja.Azure.Alerts/blob/master/doc/WebAppFixes.md")
            Criteria             = { New-AzMetricAlertRuleV2Criteria -MetricName 'Http5xx' -TimeAggregation Total -Operator GreaterThan -Threshold 5 }
            Severity             = "Warning"
            WindowSize           = New-TimeSpan -Minutes 5
            Frequency            = New-TimeSpan -Minutes 5
        }
        [PSCustomObject]@{
            ResourceType         = 'Microsoft.Web/Sites'
            Name                 = 'Many Server errors'
            Description          = 'Way too many server errors!'
            AlertValidationSteps = @("https://todo/Insights+-+Server+errors")
            AlertFixSteps        = @("https://github.com/by-pinja/Pinja.Azure.Alerts/blob/master/doc/WebAppFixes.md")
            Criteria             = { New-AzMetricAlertRuleV2Criteria -MetricName 'Http5xx' -TimeAggregation Total -Operator GreaterThan -Threshold 100 }
            Severity             = "Critical"
            WindowSize           = New-TimeSpan -Minutes 5
            Frequency            = New-TimeSpan -Minutes 5
        }
        [PSCustomObject]@{
            ResourceType  = 'Microsoft.Web/serverFarms'
            Name          = 'CPU percentage'
            Description   = 'CPU Usage too high!'
            AlertFixSteps = @("https://todo/Performance+scaling+-+WebApp")
            Criteria      = { New-AzMetricAlertRuleV2Criteria -MetricName 'CpuPercentage' -TimeAggregation Average -Operator GreaterThan -Threshold 80 }
            Severity      = "Warning"
            WindowSize    = New-TimeSpan -Minutes 5
            Frequency     = New-TimeSpan -Minutes 5
        }
        [PSCustomObject]@{
            ResourceType = 'Microsoft.Web/serverFarms'
            Name         = 'Memory percentage'
            Description  = 'Memory Usage too high!'
            Criteria     = { New-AzMetricAlertRuleV2Criteria -MetricName 'MemoryPercentage' -TimeAggregation Average -Operator GreaterThan -Threshold 80 }
            Severity     = "Warning"
            WindowSize   = New-TimeSpan -Minutes 5
            Frequency    = New-TimeSpan -Minutes 5
        }
        [PSCustomObject]@{
            ResourceType = 'Microsoft.Sql/servers/databases'
            Name         = 'CPU Percentage'
            Description  = 'CPU Usage too high!'
            Criteria     = { New-AzMetricAlertRuleV2Criteria -MetricName 'cpu_percent' -TimeAggregation Average -Operator GreaterThan -Threshold 80 }
            Severity     = "Information"
            WindowSize   = New-TimeSpan -Minutes 5
            Frequency    = New-TimeSpan -Minutes 5
        }
        [PSCustomObject]@{
            ResourceType = 'Microsoft.Sql/servers/databases'
            Name         = 'DTU consumption'
            Description  = 'DTU consumption too high!'
            Criteria     = { New-AzMetricAlertRuleV2Criteria -MetricName 'dtu_consumption_percent' -TimeAggregation Average -Operator GreaterThan -Threshold 80 }
            Severity     = "Information"
            WindowSize   = New-TimeSpan -Minutes 5
            Frequency    = New-TimeSpan -Minutes 5
        }
        [PSCustomObject]@{
            ResourceType  = 'Microsoft.Sql/servers/databases'
            Name          = 'SQL Storage'
            Description   = 'SQL storage space is getting low!'
            AlertFixSteps = @("https://github.com/by-pinja/Pinja.Azure.Alerts/blob/master/doc/SqlServerStorageSize.md")
            Criteria      = { New-AzMetricAlertRuleV2Criteria -MetricName 'storage_percent' -TimeAggregation Average -Operator GreaterThan -Threshold 80 }
            Severity      = "Error"
            WindowSize    = New-TimeSpan -Minutes 5
            Frequency     = New-TimeSpan -Minutes 5
        }
        [PSCustomObject]@{
            ResourceType = 'Microsoft.Cache/Redis'
            Name         = 'Server load'
            Description  = 'Server load too high!'
            Criteria     = { New-AzMetricAlertRuleV2Criteria -MetricName 'serverLoad' -TimeAggregation Average -Operator GreaterThan -Threshold 80 }
            Severity     = "Information"
            WindowSize   = New-TimeSpan -Minutes 5
            Frequency    = New-TimeSpan -Minutes 5
        }
        [PSCustomObject]@{
            ResourceType = 'Microsoft.Cache/Redis'
            Name         = 'Server memory'
            Description  = 'Server memory percentace too high!'
            Criteria     = { New-AzMetricAlertRuleV2Criteria -MetricName 'usedmemorypercentage' -TimeAggregation Average -Operator GreaterThan -Threshold 80 }
            Severity     = "Information"
            WindowSize   = New-TimeSpan -Minutes 5
            Frequency    = New-TimeSpan -Minutes 5
        }
        [PSCustomObject]@{
            ResourceType = 'Microsoft.Cache/Redis'
            Name         = 'Redis processor'
            Description  = 'Redis processor load too high!'
            Criteria     = { New-AzMetricAlertRuleV2Criteria -MetricName 'percentProcessorTime' -TimeAggregation Average -Operator GreaterThan -Threshold 80 }
            Severity     = "Information"
            WindowSize   = New-TimeSpan -Minutes 5
            Frequency    = New-TimeSpan -Minutes 5
        }
        [PSCustomObject]@{
            ResourceType         = 'Microsoft.Insights/webtests'
            Name                 = "Availability percent"
            Description          = "Web app didn't respond multiple times in timely manner!"
            AlertValidationSteps = @("https://todo/Insights+-+Server+errors")
            AlertFixSteps        = @("https://github.com/by-pinja/Pinja.Azure.Alerts/blob/master/doc/WebAppFixes.md")
            Criteria             = {
                New-AzMetricAlertRuleV2DimensionSelection -DimensionName "availabilityResult/name" -ValuesToInclude $($_.Name) |
                New-AzMetricAlertRuleV2Criteria -MetricName "availabilityResults/availabilityPercentage" -TimeAggregation Average -Operator LessThan -Threshold 90
            }
            Severity             = "Critical"
            WindowSize           = New-TimeSpan -Minutes 5
            Frequency            = New-TimeSpan -Minutes 5
        }
    )
}