<# 
.SYNOPSIS
    Export a list of all groups
.DESCRIPTION 
    Export a list with all Groups to a CSV
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2024-02-07 (YYYY-MM-DD)
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#region Variables
$Global:ErrorActionPreference = 'Stop'
$RootLocation = 'C:\Temp'
$LogFile = "$($RootLocation)\Logs\Log$(Get-Date -Format 'yyyyMM').txt"
$ExportFile = "$($RootLocation)\Exports\Export.csv"
# Graph Connection 
$TenantId = 'd4fb8b6e-8be8-4e16-bac7-80f408b457ff'
$ApplicationId = '0bceae8e-9fb0-4a53-be09-32b227cfd093'
$CertificateThumbPrint = '97FA2784B3D434F414B580C1357BB25C99A2A46F'
#endregion 

#region Functions
#region Ensure TLS 1.2
Function ForceTLS {
    Try {
        If ([Net.SecurityProtocolType]::Tls12 -bor $False) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Write-Log "`t Forced TLS 1.2 since its not server default"
        } Else {
            Write-Log "`t TLS 1.2 already configured as server default"
        }
    } Catch {
        Write-Log "`t Unable to check or ensure TLS 1.2 status"
        Write-Log "`t Error: $($_.Exception.Message)"
    }
}
#endregion
#region Check Log File Location
Function CheckFilePath {
    If (Test-Path -Path "$($RootLocation)\Logs\") {}Else {
        New-Item "$($RootLocation)\Logs" -ItemType Directory
    }
    If (Test-Path -Path "$($RootLocation)\Exports\") {}Else {
        New-Item "$($RootLocation)\Exports" -ItemType Directory
    }
}
#endregion
#region Write Log
function Write-Log {
    param (
        $Message,
        $ForegroundColor = 'White'
    )
    function TimeStamp { return '[{0:yyyy/MM/dd} {0:HH:mm:ss}]' -f (Get-Date) }

    "$(TimeStamp) $Message" | Tee-Object -FilePath $LogFile -Append | Write-Verbose
    Write-Host $Message -ForegroundColor $ForegroundColor
}
#endregion
#endregion

#region Execution
Try {
    CheckFilePath
} Catch {
    Write-Host "`t Unable to check folders for logs"
    Write-Host "`t Error: $($_.Exception.Message)"
}
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==          Export All Groups            =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Enforce TLS 1.2"
    ForceTLS
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 2 - Connecting to Exchange Online"
    Connect-ExchangeOnline
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 3 - Connecting to Microsoft Graph"
    Connect-MgGraph -ClientId $ApplicationId -CertificateThumbprint $CertificateThumbPrint -TenantId $TenantId
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 4 - Colecting All information"
    $LicensedAccounts = Get-MgUser -All -Filter 'assignedLicenses/$count ne 0' -ConsistencyLevel eventual -CountVariable licensedUserCount -Property UserPrincipalName, DisplayName,assignedLicenses,LicenseAssignmentState
    Foreach ($Account in $LicensedAccounts) {
        $User = $Account.UserPrincipalName
        $MailboxUser = Get-EXOMailbox -Identity $User
        $MailboxStatistics = Get-EXOMailboxStatistics -Identity $User
        $ArchiveStatus = Get-Mailbox -Identity $User | Select-Object ArchiveStatus
        If ($ArchiveStatus.ArchiveStatus -like "Active") {
            $MailboxArchive = Get-EXOMailboxStatistics -Identity $User -Archive
        } Else {
            $MailboxArchive = 'Disabled'
        }
        
        $UserData = [PSCustomObject]@{
            'TimeStamp'   = Get-Date -Format 'yyyy-MM-dd'
            'DisplayName' = $MailboxUser.DisplayName
            'Account'     = $MailboxUser.Alias
            'MailboxSize' = $MailboxStatistics.TotalItemSize
            'ArchiveSize' = $MailboxArchive.TotalItemSize
        }
        $UserData | Export-Csv $ExportFile -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion