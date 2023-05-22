<# 
.SYNOPSIS
    Export OneDrive Quotas
.DESCRIPTION 
    Export a OneDrive usage report
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
#Export
$ExportPath = '.\Microsoft-PowerShell-Fastlane\Exports\'
$ExportFile = 'OneDriveQuota.csv'
$ExportFilePath = "$($ExportPath)$($ExportFile)"
#User
$OneDriveUserURL = 'domain-my.sharepoint.com/personal/User_Name'
#endregion 

#region Functions

#endregion

#region Execution
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==         User OneDrive Quotas          =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Connecting to SharePoint Online"
    Connect-SPO
} Catch {
    Write-Log "`t Step 1.1 - Unable to tonnec to SharePoint Online"
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 2 - Gathering and exporting information"
    $Info = Get-SPOSite -IncludePersonalSite $True -Limit ALL -Filter "URL -like $($OneDriveUserURL)" Select-Object Owner, StorageQuota, StorageUsageCurrent
    $Info | Export-Csv $ExportFilePath -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
} Catch {
    Write-Log "`t Step 2.1 - Unable to gather and export information"
    Write-Log "`t Error: $($_.Exception.Message)"
}

Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion