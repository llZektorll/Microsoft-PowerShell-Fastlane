<# 
.SYNOPSIS
    A summary of how the script works and how to use it.
.DESCRIPTION 
    A long description of how the script works and how to use it.
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2023-04-20 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    Information about PowerShell Modules to be required.
        NA
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#Adding the configuration file to be ran 
. '.\Microsoft-PowerShell-Fastlane\1-ToolKits\TK0-Config.ps1'

#region Variables
# Modules to Install
$Modules = @(
    'AzureAD',
    'ExchangeOnlineManagement',
    'Microsoft.Graph',
    'Microsoft.Online.SharePoint.PowerShell',
    'MicrosoftTeams',
    'PNP.PowerShell'
)

#endregion 

#region Execution

Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==            TK1 New Machine            =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Installing Modules"
    $Step = 1
    Foreach ($Module in $Modules) {
        Try {
            Install-Module -Name $Module -Confirm:$False -Force
            Write-Log "`t Step 1.$Step - Module $Module installed"
            $Step++
        } Catch {
            Write-Log "`t Step 1.1 - Unable to install $Module Module"
            Write-Log "`t Error: $($_.Exception.Message)"
        }
    }
    Write-Log "`t Step 2 - All Modules installed"
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion