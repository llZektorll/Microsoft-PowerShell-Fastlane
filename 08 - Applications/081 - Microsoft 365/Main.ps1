<# 
.DESCRIPTION 
    This script will create a UI for the configurations and costumization of Microsoft 365
.NOTES 
    Version:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2025-01-19 (YYYY-MM-DD)
#>

#Enforce running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}

# Load DLLs
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

#region Variables 
#Global Variables
[String]$Root_Path = Get-Location
#Version Control
$Sync = [hashtable]::Synchronized(@{})
$Sync.PSScriptRoot = $Root_Path
$Sync.Version = '0.0.2'
$Sync.Config = @{}
$sync.ProcessRunning = $false
#endregion

#Sync Configurations

If($Sync.ProcessRunning -eq $false){
    #Question user to check for updates
    $Check_Updates = [System.Windows.MessageBox]::Show("Do you want to check for updates", "MPFL - M365", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
    If($Check_Updates -match "Yes"){
        #Connect to the GitHub repository and check for updates
        $Repo
    }Else{
        Continue
    }
}
