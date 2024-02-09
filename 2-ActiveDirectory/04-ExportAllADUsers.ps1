<# 
.SYNOPSIS
    Export All AD Users
.DESCRIPTION 
    Export all users on Active Directory
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2024-01-28 (YYYY-MM-DD)
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#region Variables
$Global:ErrorActionPreference = 'Stop'
$RootLocation = 'C:\Temp'
$LogFile = "$($RootLocation)\Logs\Log$(Get-Date -Format 'yyyyMM').txt"
$ExportFile = "$($RootLocation)\Exports\ExportAllADUsers.csv"
# Users to Export
$Properties = @(
    'Name',
    'UserPrincipalName',
    'distinguishedName'
    'mail',
    'extensionAttribute2',
    'extensionAttribute3',
    'extensionAttribute5'
)
# OU Location
$OU = 'DC=contoso,DC=com'
#endregion 

#region Functions
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
Write-Log "`t ==         Export All User in AD         =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Collecting Users"
    $GetUsers = Get-ADUser -SearchBase $OU -Properties $Properties | Select-Object $Properties
    Write-Log "`t Step 1.2 - Exporting Informaiton"
    Try {
        Foreach ($User in $GetUsers) {
            $ObjectDetail = [PSCustomObject][Ordered]@{
                'Name'                = $User.Name
                'UserPrincipalName'   = $User.UserPrincipalName
                'distinguishedName'   = $User.distinguishedName
                'mail'                = $User.mail
                'extensionAttribute2' = $User.extensionAttribute2
                'extensionAttribute3' = $User.extensionAttribute3
                'extensionAttribute5' = $User.extensionAttribute5
            }
            $ObjectDetail | Export-Csv $ExportFile -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
        }
        Write-Log "`t Step 1.3 - Export compleated"
    } Catch {
        Write-Log "`t Error: $($_.Exception.Message)"
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}

Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion