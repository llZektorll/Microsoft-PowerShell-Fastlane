<# 
.DESCRIPTION 
    Application Builder
.NOTES 
    Version:   1.0.0
    Author: Hugo Santos 
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-01-19 (YYYY-MM-DD)
#>
param (
    [switch]$Debug
)

#region Variables
$Script_Name = "MicrosftPowerShellFastlane-M365.ps1"
$Script_Dir = $PSScriptRoot

#endregion

#region Main
Push-Location
Set-Location $Script_Dir

#Check if the script already exists
If ((Get-Item $Script_Name -ErrorAction SilentlyContinue)) {
    Remove-Item $Script_Name -Force
}

Function Compilation {
    #Script Compitlation
    $Script_Content = [System.Collections.Generic.List[string]]::new()

    $Header = Get-Content -Path "$($Script_Dir)\Resources\Header.ps1" -Raw
    $Script_Content.Add($Header)

    $Variables = Get-Content -Path "$($Script_Dir)\Resources\Variables.ps1" -Raw
    $Script_Content.Add($Variables)

    $Functions = Get-Content -Path "$($Script_Dir)\Resources\Functions.ps1" -Raw
    $Script_Content.Add($Functions)

    $Footer = Get-Content -Path "$($Script_Dir)\Resources\Footer.ps1" -Raw
    $Script_Content.Add($Footer)

    Set-Content -Path "$($Script_Dir)\$($Script_Name)" -Value ($script_content -join "`r`n") -Encoding UTF8
}
Compilation
#endregion