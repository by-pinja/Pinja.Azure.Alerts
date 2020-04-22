[CmdLetBinding(SupportsShouldProcess)]
Param(
    [string][Parameter(Mandatory)]$ResourceGroup,
    [PsCustomObject[]][Parameter(Mandatory)]$AlertRules
)

Set-StrictMode -Version Latest

$resources = Get-AzResource -ResourceGroupName $ResourceGroup

function ResolveDescription([PsCustomObject]$mathingAlertRule, [PsCustomObject]$resource) {
    [System.Collections.ArrayList]$alertValidations = @()
    [System.Collections.ArrayList]$alertFixSteps = @()
    if ("AlertValidationSteps" -in $mathingAlertRule.PsObject.Properties.Name) {
        $alertValidations.AddRange($mathingAlertRule.AlertValidationSteps)
    }

    if ("AlertFixSteps" -in $mathingAlertRule.PsObject.Properties.Name) {
        $alertFixSteps.AddRange($mathingAlertRule.AlertFixSteps)
    }

    return "$($mathingAlertRule.Description) " +
    "$(if($alertValidations) {"Validation steps: $alertValidations /"}) " +
    "$(if($alertFixSteps) {"Fix steps: $alertFixSteps"})"
}

function FormatCriteriaObject([Microsoft.Azure.Commands.Insights.OutputClasses.PSMetricCriteria] $criteriaToSimplify, $rule)
{
    return [PSCustomObject]@{
        Metric = $criteriaToSimplify.MetricName
        Threshold = $criteriaToSimplify.Threshold
        Aggregation = $criteriaToSimplify.TimeAggregation
        WindowSize = $rule.WindowSize
    }
}

foreach($resource in $resources)
{
    Write-Verbose "Checking alert rules for resource $($resource.Id)"

    $matchingRules = $AlertRules | where { $_.ResourceType -eq $resource.ResourceType }

    foreach($matchingRule in $matchingRules)
    {
        if(($matchingRule.PsObject.Properties -contains "Filter") )
        {
        }

        $fullName = "$($matchingRule.Name)-$($resource.Name -replace '/','-')"
        $fullDescription = ResolveDescription $matchingRule $resource

        Write-Verbose "Applying alert rule $($matchingRule.Name) to $($resource.Id)"

        # There is very anonying warning that some namespace of class is going to change one day in future. For that reason all warnings are suppressed.
        # This isn't ideal solution however (3>$null).
        $criteria = Invoke-Command -ScriptBlock $matchingRule.Criteria -InputObject $resource 3>$null

        if($PSCmdlet.ShouldProcess($fullName,$resource.Id))
        {
            Add-AzMetricAlertRuleV2 `
            -Name $fullName `
            -ResourceGroupName $ResourceGroup `
            -WindowSize $matchingRule.WindowSize `
            -Frequency $matchingRule.Frequency `
            -TargetResourceScope $resource.ResourceId `
            -TargetResourceType $resource.ResourceType `
            -TargetResourceRegion $resource.Location `
            -Description $fullDescription `
            -Severity $matchingRule.Severity `
            -Condition $criteria `
            -ActionGroup $alertRef | Out-Null
        }

        [PsCustomObject]@{
            Name = $fullName
            Resource = $resource.Id
            Description = $fullDescription
            Criteria = FormatCriteriaObject $criteria $matchingRule
        }
    }
}