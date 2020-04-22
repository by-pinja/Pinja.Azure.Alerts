$alertRules = .\Get-DefaultAlertRules.ps1
.\Apply-AlertRules.ps1 -ResourceGroup pekantesti1 -AlertRules $alertRules -WhatIf