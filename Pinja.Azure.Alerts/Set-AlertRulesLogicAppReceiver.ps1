
function Set-AlertRulesLogicAppReceiver {
    <#
    .SYNOPSIS
    Set alert rules to resource group.

    .DESCRIPTION
    Set alert rules to resource group. Get all resources from group and applies all given alert rules, overwrites if defined with
    default alert group `azure-alerts`. You must supply action group receiver where alerts are sent when triggered.

    .PARAMETER ResourceGroup
    Resource group in azure.

    .PARAMETER AlertRules
    In simplest form output from Get-DefaultAlertRules, rules that will be applied based on resource type.

    .PARAMETER OverWrites
    You can overwrite specific alerts in specific resources when needed. See Get-AlertRuleOverwrite for more information.

    .PARAMETER ActionGroupLogicAppReceiver
    Parameter description

    .PARAMETER DisableAlerts
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [CmdLetBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject[]])]
    Param(
        [string][Parameter(Mandatory)]$ResourceGroup,
        [PsCustomObject[]][Parameter(Mandatory, ValueFromPipeline)]$AlertRules,
        [PsCustomObject[]][Parameter()]$OverWrites = @(),
        [Parameter(Mandatory)]$ActionGroupLogicAppReceiver,
        [switch][Parameter()]$DisableAlerts
    )

    Begin {
        Set-StrictMode -Version Latest

        $resources = Get-AzResource -ResourceGroupName $ResourceGroup

        function SeverityAsInt([string]$Severity) {
            switch ($Severity) {
                "Critical" { return 0 }
                "Error" { return 1 }
                "Warning" { return 2 }
                "Information" { return 3 }
                Default { throw "Invalid option for severity $Severity" }
            }
        }

        function ConcatStepTexts([string[]]$new, [string[]]$old, [string]$howToConcat) {
            switch ($howToConcat) {
                "Before" { return $new + $old }
                "After" { return $old + $new }
                "Replace" { return $new }
                Default { }
            }
        }

        function ApplyOverwrite([PsCustomObject]$mathingAlertRule, [PsCustomObject]$overWrite) {
            if ($overWrite.FixSteps) {
                $mathingAlertRule.AlertFixSteps = ConcatStepTexts $overWrite.FixSteps $mathingAlertRule.AlertFixSteps $overWrite.FixStepsLocation
            }

            if ($overWrite.ValidationSteps) {
                $mathingAlertRule.AlertValidationSteps = ConcatStepTexts $overWrite.ValidationSteps $mathingAlertRule.AlertValidationSteps $overWrite.ValidationStepsLocation
            }

            if ($overWrite.Severity) {
                $mathingAlertRule.Severity = $overWrite.Severity
            }

            if ($overWrite.Criteria) {
                $mathingAlertRule.Criteria = $overWrite.Criteria
            }

            if ($overWrite.WindowSize) {
                $mathingAlertRule.WindowSize = $overWrite.WindowSize
            }

            if ($overWrite.Frequency) {
                $mathingAlertRule.Frequency = $overWrite.Frequency
            }
        }

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

        function FormatCriteriaObject([Microsoft.Azure.Commands.Insights.OutputClasses.PSMetricCriteria] $criteriaToSimplify, $rule) {
            return [PSCustomObject]@{
                Metric      = $criteriaToSimplify.MetricName
                Threshold   = $criteriaToSimplify.Threshold
                Aggregation = $criteriaToSimplify.TimeAggregation
                WindowSize  = $rule.WindowSize
            }
        }


        if ($PSCmdlet.ShouldProcess($ResourceGroup, "Update-AzActionGroug - azure-alerts")) {
            if (Get-AzActionGroup -Name "azure-alerts" -ResourceGroup $ResourceGroup) {
                $alertRef = Update-AzActionGroup `
                    -Name "azure-alerts" `
                    -ResourceGroup $ResourceGroup `
                    -ShortName "azure-alerts" `
                    -LogicAppReceiver $ActionGroupLogicAppReceiver `
                    -Location Global `
                    -Enabled:(!$DisableAlerts)
            }
            else {
                $alertRef = New-AzActionGroup `
                    -Name "azure-alerts" `
                    -ResourceGroup $ResourceGroup `
                    -ShortName "azure-alerts" `
                    -LogicAppReceiver $ActionGroupLogicAppReceiver `
                    -Location Global `
                    -Enabled:(!$DisableAlerts)
            }
            
        }
    }

    Process {
        foreach ($rule in $AlertRules) {

            $matchingResources = $resources | where { $_.ResourceType -eq $rule.ResourceType }

            foreach ($resource in $matchingResources) {
                $applicapleOverwrites = $overWrites | where { $_.ResourceType -eq $rule.ResourceType -and $_.Name -eq $rule.Name }

                foreach ($overwrite in $applicapleOverwrites) {
                    ApplyOverwrite $rule $overWrite
                }

                $fullName = "$($rule.Name)-$($resource.Name -replace '/','-')"
                $fullDescription = ResolveDescription $rule $resource

                Write-Verbose "Applying alert rule $($rule.Name) to $($resource.Id)"

                # There is very anonying warning that some namespace of class is going to change one day in future (which cannot be fixed atm). For that reason all warnings are suppressed.
                # This isn't ideal solution however (3>$null).
                $criteria = Invoke-Command -ScriptBlock $rule.Criteria -InputObject $resource 3>$null

                if ($PSCmdlet.ShouldProcess($resource.Id, $fullName)) {
                    Add-AzMetricAlertRuleV2 `
                        -Name $fullName `
                        -ResourceGroupName $ResourceGroup `
                        -WindowSize $rule.WindowSize `
                        -Frequency $rule.Frequency `
                        -TargetResourceScope $resource.ResourceId `
                        -TargetResourceType $resource.ResourceType `
                        -TargetResourceRegion $resource.Location `
                        -Description $fullDescription `
                        -Severity (SeverityAsInt $rule.Severity) `
                        -Condition $criteria `
                        -ActionGroupId $alertRef.Id | Out-Null
                }

                [PsCustomObject]@{
                    Name        = $fullName
                    Resource    = $resource.Id
                    Description = $fullDescription
                    Criteria    = FormatCriteriaObject $criteria $rule
                }
            }
        }
    }
}
