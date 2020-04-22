<#
    .SYNOPSIS
    Creates alert action group and alerts for resource groups.
    .DESCRIPTION
    This script makes sure that this resource groups has alerts configured
    for resources. This creates alert, alert action group and webhook which
    send alerts to separate application which sends the alert to Slack.
    For more information about this alert handling, see
    https://github.com/protacon/azure-slack-alert-integration
#>
[CmdLetBinding()]
Param(
    [PsCustomObject][Parameter(Mandatory)]$Config,
    [switch]$SkipAlertGroup
)

Set-StrictMode -Version Latest

$severityCritical = 0
$severityError = 1
$severityWarning = 2
$severityInformation = 3

Write-Host "Webhook " $Config.alert.webhook
$webHookReceiver = New-AzActionGroupReceiver `
    -Name 'FunctionAppWebHook' `
    -WebhookReceiver ` -ServiceUri $Config.alert.webhook `
    -UseCommonAlertSchema

# this also creates the target group
Set-AzActionGroup `
    -Name $Config.alert.actionGroupName `
    -ResourceGroup $Config.ResourceGroup `
    -ShortName $Config.alert.actionGroupName `
    -Receiver $webHookReceiver `
    -DisableGroup:$SkipAlertGroup # In test environments we want to disable outgoing alerts for slack etc.

Write-Host 'Retrieving alert action group...'
$alertTargetActual = Get-AzActionGroup -ResourceGroupName $Config.ResourceGroup -Name $Config.alert.actionGroupName
$alertRef = New-AzActionGroup -ActionGroupId $alertTargetActual.Id

$alertRules = @(
    [PSCustomObject]@{
        ResourceType = 'Microsoft.Web/Sites'
        Rules        = @(
            [PSCustomObject]@{
                Name                        = 'Few Server errors'
                Description                 = 'Too many server errors!'
                DefaultAlertValidationSteps = @("https://todo/Insights+-+Server+errors")
                DefaultAlertFixSteps        = @("https://todo/Fixing+web+app")
                Criteria                    = New-AzMetricAlertRuleV2Criteria -MetricName 'Http5xx' -TimeAggregation Total -Operator GreaterThan -Threshold 5
                Severity                    = $severityWarning
            }
            [PSCustomObject]@{
                Name                        = 'Many Server errors'
                Description                 = 'Way too many server errors!'
                DefaultAlertValidationSteps = @("https://todo/Insights+-+Server+errors")
                DefaultAlertFixSteps        = @("https://todo/Fixing+web+app")
                Criteria                    = New-AzMetricAlertRuleV2Criteria -MetricName 'Http5xx' -TimeAggregation Total -Operator GreaterThan -Threshold 100
                Severity                    = $severityCritical
            }
        )
    }
    [PSCustomObject]@{
        ResourceType = 'Microsoft.Web/serverFarms'
        Rules        = @(
            [PSCustomObject]@{
                Name                 = 'CPU percentage'
                Description          = 'CPU Usage too high!'
                DefaultAlertFixSteps = @("https://todo/Performance+scaling+-+WebApp")
                Criteria             = New-AzMetricAlertRuleV2Criteria -MetricName 'CpuPercentage' -TimeAggregation Average -Operator GreaterThan -Threshold 80
                Severity             = $severityWarning
            }
            [PSCustomObject]@{
                Name        = 'Memory percentage'
                Description = 'Memory Usage too high!'
                Criteria    = New-AzMetricAlertRuleV2Criteria -MetricName 'MemoryPercentage' -TimeAggregation Average -Operator GreaterThan -Threshold 80
                Severity    = $severityWarning
            }
        )
    }
    [PSCustomObject]@{
        ResourceType = 'Microsoft.Cache/Redis'
        Rules        = @(
            [PSCustomObject]@{
                Name        = 'Server load'
                Description = 'Server load too high!'
                Criteria    = New-AzMetricAlertRuleV2Criteria -MetricName 'serverLoad' -TimeAggregation Average -Operator GreaterThan -Threshold 80
                Severity    = $severityInformation
            }
            [PSCustomObject]@{
                Name        = 'Server memory'
                Description = 'Server memory percentace too high!'
                Criteria    = New-AzMetricAlertRuleV2Criteria -MetricName 'usedmemorypercentage' -TimeAggregation Average -Operator GreaterThan -Threshold 80
                Severity    = $severityInformation
            }
            [PSCustomObject]@{
                Name        = 'Redis processor'
                Description = 'Redis processor load too high!'
                Criteria    = New-AzMetricAlertRuleV2Criteria -MetricName 'percentProcessorTime' -TimeAggregation Average -Operator GreaterThan -Threshold 80
                Severity    = $severityInformation
            }
        )
    }
    [PSCustomObject]@{
        ResourceType = 'Microsoft.Sql/servers/databases'
        Rules        = @(
            [PSCustomObject]@{
                Name        = 'CPU Percentage'
                Description = 'CPU Usage too high!'
                Criteria    = New-AzMetricAlertRuleV2Criteria -MetricName 'cpu_percent' -TimeAggregation Average -Operator GreaterThan -Threshold 80
                Severity    = $severityInformation
            }
            [PSCustomObject]@{
                Name        = 'DTU consumption'
                Description = 'DTU consumption too high!'
                Criteria    = New-AzMetricAlertRuleV2Criteria -MetricName 'dtu_consumption_percent' -TimeAggregation Average -Operator GreaterThan -Threshold 80
                Severity    = $severityInformation
            }
            [PSCustomObject]@{
                Name                 = 'SQL Storage'
                Description          = 'SQL storage space is getting low!'
                DefaultAlertFixSteps = @("https://todo/Database+-+Storage+size")
                Criteria             = New-AzMetricAlertRuleV2Criteria -MetricName 'storage_percent' -TimeAggregation Average -Operator GreaterThan -Threshold 80
                Severity             = $severityError
            }
        )
    }
)

$webAppTests = Get-AzResource -ResourceGroupName $Config.ResourceGroup -ResourceType 'Microsoft.Insights/webtests'
$rules = @()
Foreach ($webApp in $webAppTests) {
    $rules += [PSCustomObject]@{
        Name                        = "Availability percent-$($webApp.Name)"
        Description                 = "$($webApp.Name) didnt respond multiple times in timely manner!"
        DefaultAlertValidationSteps = @("https://todo/Insights+-+Server+errors")
        DefaultAlertFixSteps        = @("https://todo/Fixing+web+app")
        Criteria                    = New-AzMetricAlertRuleV2DimensionSelection -DimensionName "availabilityResult/name" -ValuesToInclude $($webApp.Name) | New-AzMetricAlertRuleV2Criteria -MetricName "availabilityResults/availabilityPercentage" -TimeAggregation Average -Operator LessThan -Threshold 90
        Severity                    = $severityCritical
    }
}

$alertRules += [PSCustomObject]@{
    ResourceType = 'microsoft.insights/components'
    Rules        = $rules
}

function ResolveDescription([PsCustomObject]$mathingAlertRule, [PsCustomObject]$resource) {
    [System.Collections.ArrayList]$alertValidations = @()
    [System.Collections.ArrayList]$alertFixSteps = @()

    if ($resource.ResourceType -in "microsoft.insights/components", "Microsoft.Web/Sites") {
        $matchingWebAppInConfig = $Config.webApps | where { $_.WebAppFullName -eq $resource.Name }

        if ($matchingWebAppInConfig -and ("alertValidationSteps" -in $matchingWebAppInConfig.PsObject.Properties.Name)) {
            $alertValidations.AddRange(@($matchingWebAppInConfig.alertValidationSteps))
        }

        if ($matchingWebAppInConfig -and ("alertFixSteps" -in $matchingWebAppInConfig.PsObject.Properties.Name)) {
            $alertFixSteps.AddRange(@($matchingWebAppInConfig.alertFixSteps))
        }
    }

    if ("DefaultAlertValidationSteps" -in $mathingAlertRule.PsObject.Properties.Name) {
        $alertValidations.AddRange($mathingAlertRule.DefaultAlertValidationSteps)
    }

    if ("DefaultAlertFixSteps" -in $mathingAlertRule.PsObject.Properties.Name) {
        $alertFixSteps.AddRange($mathingAlertRule.DefaultAlertFixSteps)
    }

    return "$($mathingAlertRule.Description) " +
    "$(if($alertValidations) {"Validation steps: $alertValidations /"}) " +
    "$(if($alertFixSteps) {"Fix steps: $alertFixSteps"})"
}

$allResources = Get-AzResource -ResourceGroupName $Config.ResourceGroup
Foreach ($resource in $allResources) {
    # Find matching rules
    $matchingAlerts = $alertRules | Where-Object { $_.ResourceType -eq $resource.ResourceType } | Select-Object -ExpandProperty Rules
    Foreach ($alertParameter in $matchingAlerts) {
        Write-Host "Creating alert $($alertParameter.Name) for $($resource.ResourceType) $($resource.Name)"
        Add-AzMetricAlertRuleV2 `
            -Name "$($alertParameter.Name)-$($resource.Name -replace '/','-')" `
            -ResourceGroupName $Config.ResourceGroup `
            -WindowSize 0:5 `
            -Frequency 0:5 `
            -TargetResourceScope $resource.ResourceId `
            -TargetResourceType $resource.ResourceType `
            -TargetResourceRegion $resource.Location `
            -Description (ResolveDescription $alertParameter $resource) `
            -Severity $alertParameter.Severity `
            -Condition $alertParameter.Criteria `
            -ActionGroup $alertRef
    }
}