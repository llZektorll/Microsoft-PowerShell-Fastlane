<# 
.SYNOPSIS
    Add users to AD Group
.DESCRIPTION 
    Add to Active Directory groups multiple users from a CSV file
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
#Goup Informaiton
$ADGroup = 'MyGoup'
$UserList = (Import-Csv -Path 'C:\Temp\File.csv' -Delimiter ',').User
#endregion 

#region Functions

#region Check Log File Location
Function CheckFilePath {
    If (Test-Path -Path "$($RootLocation)\Logs\") {}Else {
        New-Item "$($RootLocation)\Logs" -ItemType Directory
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
Write-Log "`t ==        ADD Users to AD Group          =="
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
    Write-Log "`t Step 2 - Adding users to the Group: $($ADGroup)"
    Foreach ($Account in $UserList) {
        $Acc = Get-ADUser -Filter "$User -eq '$Account'" | Select-Object ObjectGUID
        If ($Acc) {
            Add-ADGroupMember -Identity $Group -Members $Acc
            Write-Log "`t Step 2.1 - User: $($Acc) added to thr group $($Group)"
        } Else {
            Write-Log "`t Error 2.1 - Unable to find or add the user $($Acc)"
        }
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}

Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion