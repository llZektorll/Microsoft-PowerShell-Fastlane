<# 
.SYNOPSIS
    A summary of how the script works and how to use it.
.DESCRIPTION 
    A long description of how the script works and how to use it.
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2023-MM-DD (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    Connection modules include 
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#Adding the configuration file to be ran 
. '.\Microsoft-PowerShell-Fastlane\1-ToolKits\TK0-Config.ps1'
#region Variables

#endregion 

#region Functions

#endregion

#region Execution
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==            My Script Name             =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - "
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}

Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion