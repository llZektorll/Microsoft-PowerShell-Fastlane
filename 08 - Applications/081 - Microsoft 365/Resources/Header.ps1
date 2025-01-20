<# 
.DESCRIPTION 
    This script will create a UI for the configurations and costumization of Microsoft 365
.NOTES 
    Version:   0.0.1
    Author: Hugo Santos 
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-01-19 (YYYY-MM-DD)
#>

#Enforce running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}
# Load DLLs
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()


$Gui = New-Object System.Windows.Forms.Form
$Gui.Text = "MPFL - Microsoft 365"
$Gui.AutoSize = $true
$Gui.AutoScale = $true