[CmdletBinding()]
Param(
    [string][Parameter(Mandatory)]$ResourceType,
    [string][Parameter(Mandatory)]$Name,

    [scriptblock][Parameter(Mandatory)]$ResourceFilter,

    [string[]][Parameter()]$FixSteps,
    [ValidateSet("Before", "After", "Replace")]
    [string][Parameter()]$FixStepsLocation = "Before",

    [string[]][Parameter()]$ValidationSteps,
    [ValidateSet("Before", "After", "Replace")]
    [string][Parameter()]$ValidationStepsLocation = "Before",

    [ValidateSet("Critical", "Error", "Warning", "Information")]
    [string][Parameter()]$Severity,

    [ScriptBlock][Parameter()]$Criteria,

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
        SpecialRuleType              = "OVERWRITE"
        Name                         = $Name
        ResourceType                 = $ResourceType
        ApplyOverwriteResourceFilter = $ApplyOverwriteResourceFilter
        FixSteps                     = $FixSteps
        FixStepsLocation             = $FixStepsLocation
        ValidationSteps              = $ValidationSteps
        ValidationLocation           = $ValidationStepsLocation
        Severity                     = $Severity
        Criteria                     = $Criteria
        WindowSize                   = $WindowSize
        Frequency                    = $Frequency
    }
}