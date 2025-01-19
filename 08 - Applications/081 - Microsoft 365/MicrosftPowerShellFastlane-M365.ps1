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
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
#region Variables 
#Global Variables
[String]$Root_Path = $MyInvocation.MyCommand.Path
#Version Control
$Sync = [hashtable]::Synchronized(@{})
$Sync.PSScriptRoot = $Root_Path
$Sync.Version = '0.0.1'
$Sync.Config = @{}
$sync.ProcessRunning = $false
#Base Directory
$Log_Dir = "C:\Temp\MPFL-M365\Logs)"
$Log_Export = "C:\Temp\MPFL-M365\Export)"
#endregion
Function Sync-Update {
    If ($Sync.ProcessRunning -eq $false) {
        #Question user to check for updates
        $Check_Updates = [System.Windows.MessageBox]::Show("Do you want to check for updates", "MPFL - M365", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
        If ($Check_Updates -match "Yes") {
            #Link to Repository
            $GitHub_File = "https://raw.githubusercontent.com/llZektorll/Microsoft-PowerShell-Fastlane/refs/heads/main/08%20-%20Applications/081%20-%20Microsoft%20365/Main.ps1"
            try {
                # Fetch the file from GitHub
                $GitHub_File_Control = Invoke-WebRequest -Uri $GitHub_File -UseBasicParsing
                # Split the content into lines
                $GitHub_File_Control = $GitHub_File_Control.Content -split "`n"
                # Split the 5th line (index 4) by spaces and get the last value
                $GitHub_File_Version = ($GitHub_File_Control[4] -split " ")[-1]
            } catch {
                Write-Host "Failed to fetch the file from GitHub."
                return
            }
            # Compare versions and update if needed
        
            if ($GitHub_File_Version -match $Sync.Version) {
                [System.Windows.MessageBox]::Show("Running the latest version", "MPFL - M365", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
            } else {
                $GitHub_File = Invoke-WebRequest -Uri $GitHub_File -UseBasicParsing
                $GitHub_File.Content | Set-Content -Path $Sync.PSScriptRoot -Force -Encoding UTF8
            }
        } Else {
            Continue
        }
    }
}
