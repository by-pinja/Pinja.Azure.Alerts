function New-AlertRule {
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