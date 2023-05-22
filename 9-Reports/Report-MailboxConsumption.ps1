<# 
.SYNOPSIS
    Report consumption for mailbox and archive
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
# Export Section
$ExportPath = '.\Microsoft-PowerShell-Fastlane\Exports\'
$ExportFile = 'ReportMailboxConsumption.csv'
$ExportFilePath = "$($ExportPath)$($ExportFile)"
#endregion 

#region Functions

#endregion

#region Execution
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==         Get Mailbox Quotas            =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Connectiong to Exchange Online"
    Connect-EXO
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}

Try {
    Write-Log "`t Step 2 - Gathering users"
    $LicensedAccounts = Get-MgUser -All -Filter 'assignedLicenses/$count ne 0' -ConsistencyLevel eventual -CountVariable licensedUserCount -Property UserPrincipalName, DisplayName,assignedLicenses,LicenseAssignmentState
} Catch {
    Write-Log "`t Step 2.1 - Unable to Gather users"
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 3 - Exporting information"
    Foreach ($Account in $LicensedAccounts) {
        $User = $Account.UserPrincipalName
        $MailboxUser = Get-EXOMailbox -Identity $User
        $MailboxStatistics = Get-EXOMailboxStatistics -Identity $User
        $MailboxArchive = Get-EXOMailboxStatistics -Identity $User -Archive

        $UserData = [PSCustomObject]@{
            'TimeStamp'   = Get-Date -Format 'yyyy-MM-dd'
            'DisplayName' = $MailboxUser.DisplayName
            'Account'     = $MailboxUser.Alias
            'MailboxSize' = $MailboxStatistics.TotalItemSize
            'ArchiveSize' = $MailboxArchive.TotalItemSize
        }
        $UserData | Export-Csv $ExportFilePath -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
} Catch {
    Write-Log "`t Step 3.1 - Unable to Export information"
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion