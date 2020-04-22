[CmdletBinding()]
Param(
    [ValidateSet("Critical", "Error", "Warning", "Information")]
    [Parameter(Mandatory, Position=0)]$Severity
)

switch ($Severity) {
    "Critical" { return 0 }
    "Error" { return 1 }
    "Warning" { return 2 }
    "Information" { return 3 }
    Default { throw "Invalid option $Severity"}
}