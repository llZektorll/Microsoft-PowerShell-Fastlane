<# 
.SYNOPSIS
    Disable profile Photo
.DESCRIPTION 
    Disable user permissions to edit the profile picture in any application of Office 365
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2023-05-11 (YYYY-MM-DD)
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
Write-Log "`t ==        Disable Profile Photo          =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Connecting to Exchange online"
    Connect-EXO
} Catch {
    Write-Log "`t Step 1.1 - Unable to connect to Exchange online"
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 2 - Removing permissions to edit the photo on the default policy"
    Set-OwaMailboxPolicy -Identity OwaMailboxPolicy-Default -SetPhotoEnabled $False
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion