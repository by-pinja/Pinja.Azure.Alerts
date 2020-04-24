function Set-AlertRules {
    [CmdLetBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject[]])]
    Param(
        [string][Parameter(Mandatory)]$ResourceGroup,
        [PsCustomObject[]][Parameter(Mandatory)]$AlertRules,
        [Parameter(Mandatory)]$ActionGroupReceiver,
        [switch][Parameter()]$DisableAlerts
    )

    Begin {
        Set-StrictMode -Version Latest

        $resources = Get-AzResource -ResourceGroupName $ResourceGroup

        $overWrites = $AlertRules | where { "SpecialRuleType" -in $_.PsObject.Properties.Name -and $_.SpecialRuleType -eq "OVERWRITE" }
        $AlertRules = $AlertRules | where { "SpecialRuleType" -notin $_.PsObject.Properties.Name }

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


        $PSCmdlet.ShouldProcess($ResourceGroup, "Set-AzActionGroup - azure-alerts")
        {
            $alertRef = Set-AzActionGroup `
                -Name "azure-alerts" `
                -ResourceGroup $ResourceGroup `
                -ShortName "azure-alerts" `
                -Receiver $ActionGroupReceiver `
                -DisableGroup:$DisableAlerts `
                -WarningAction SilentlyContinue

            # See https://github.com/Azure/azure-powershell/issues/9259 ...
            $alertRef = New-AzActionGroup -ActionGroupId $alertRef.Id
        }
    }
    Process {
        foreach ($resource in $resources) {
            Write-Verbose "Checking alert rules for resource $($resource.Id)"

            $matchingRules = $AlertRules | where { $_.ResourceType -eq $resource.ResourceType }

            foreach ($matchingRule in $matchingRules) {
                $applicapleOverwrites = $overWrites | where { $_.ResourceType -eq $matchingRule.ResourceType -and $_.Name -eq $matchingRule.Name }

                foreach ($overwrite in $applicapleOverwrites) {
                    ApplyOverwrite $matchingRule $overWrite
                }

                $fullName = "$($matchingRule.Name)-$($resource.Name -replace '/','-')"
                $fullDescription = ResolveDescription $matchingRule $resource

                Write-Verbose "Applying alert rule $($matchingRule.Name) to $($resource.Id)"

                # There is very anonying warning that some namespace of class is going to change one day in future (which cannot be fixed atm). For that reason all warnings are suppressed.
                # This isn't ideal solution however (3>$null).
                $criteria = Invoke-Command -ScriptBlock $matchingRule.Criteria -InputObject $resource 3>$null

                if ($PSCmdlet.ShouldProcess($resource.Id, $fullName)) {
                    Add-AzMetricAlertRuleV2 `
                        -Name $fullName `
                        -ResourceGroupName $ResourceGroup `
                        -WindowSize $matchingRule.WindowSize `
                        -Frequency $matchingRule.Frequency `
                        -TargetResourceScope $resource.ResourceId `
                        -TargetResourceType $resource.ResourceType `
                        -TargetResourceRegion $resource.Location `
                        -Description $fullDescription `
                        -Severity (SeverityAsInt $matchingRule.Severity) `
                        -Condition $criteria `
                        -ActionGroup $alertRef | Out-Null
                }

                [PsCustomObject]@{
                    Name        = $fullName
                    Resource    = $resource.Id
                    Description = $fullDescription
                    Criteria    = FormatCriteriaObject $criteria $matchingRule
                }
            }
        }
    }
}
