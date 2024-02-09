<# 
.SYNOPSIS
    Export All AD Groups
.DESCRIPTION 
    Export all Groups in Active Directory
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
$ExportFile = "$($RootLocation)\Exports\ExportADGroups.csv"
#Groups to Export
$Properties = @(
    'Name',
    'CanonicalName',
    'GroupCategory',
    'GroupScope',
    'ManagedBy',
    'MemberOf',
    'created',
    'whenChanged',
    'mail',
    'info',
    'description'
)
# OU Lcoation
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
Write-Log "`t ==          Export Groups in AD          =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Collecting information"
    $Groups = Get-ADGroup -SearchBase $OU -Filter * -Properties $Properties | Select-Object $Properties
    Write-Log "`t Step 1.2 - Exporting Information"
    Foreach ($Group in $Groups) {
        If ($Null -ne $_.ManagedBy) {
            $Manager = Get-ADUser -Identity $_.ManagedBy | Select-Object -ExpandProperty name
        } Else {
            $Manager = 'Not Set'
        }
        $ObjectDetail = [PSCustomObject][Ordered]@{
            'Name'          = $Group.Name
            'CanonicalName' = $Group.CanonicalName
            'GroupCategory' = $Group.GroupCategory
            'GroupScope'    = $Group.GroupScope
            'Mail'          = $Group.Mail
            'Description'   = $Group.Description
            'Info'          = $Group.info
            'ManagedBy'     = $Manager
            'MemberOf'      = ($memberOf | Out-String).Trim()
            'Date created'  = $Group.created
            'Date changed'  = $Group.whenChanged
        }
        $ObjectDetail | Export-Csv $ExportFile -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
    Write-Log "`t Step 1.3 - Export Compleated"
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion