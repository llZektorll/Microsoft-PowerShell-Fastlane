<# 
.SYNOPSIS
    Hide mailbox from GAL
.DESCRIPTION 
    Hide a list of mailbox's from the GAL (Global Address List)
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2023-05-10 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    Connection modules include 
        Exchange Online
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#Adding the configuration file to be ran 
. '.\Microsoft-PowerShell-Fastlane\1-ToolKits\TK0-Config.ps1'
#region Variables
$MailboxList = Import-Csv -Path '.\Microsoft-PowerShell-Fastlane\Import\MyList.csv' #Ensure the email is in the User column
#endregion 

#region Functions

#endregion

#region Execution
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==        Hide Mailbox from GAL          =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Connecting to Excahnge Online"
    Connect-EXO
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 2 - Hiding the mailboxes in the file $($MailboxList)"
    $Users = $MailboxList.User
    $CountUsers = $Users.count
    $count = 1
    Foreach ($User in $Users) {
        $CurrentUser = $User
        Write-Progress -Activity 'Applying configuration' -Status "Current count: $($count) of $($CountUsers)" -PercentComplete (($count / $CountUsers) * 100) -CurrentOperation "Processing mailbox: $($CurrentUser)"
        Set-EXOMailbox -Identity $User -HiddenFromAddressListsEnabled $True
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}

Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion