<# 
.SYNOPSIS
    Export All AD Computers
.DESCRIPTION 
    Export all Computers registered on Active Directory
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
$ExportFile = "$($RootLocation)\Exports\ExportADComputer.csv"
# Computers to Export
$Properties = @( # -> Information that will be exported
    'Name',
    'CanonicalName',
    'OperatingSystem',
    'OperatingSystemVersion',
    'LastLogonDate',
    'LogonCount',
    'BadLogonCount',
    'IPv4Address',
    'Enabled',
    'whenCreated'
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
Write-Log "`t ==        Export Computer in AD          =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Collecting information"
    $Equipment = Get-ADComputer -Filter * -SearchBase $OU -Properties $Properties | Select-Object $Properties
    Write-Log "`t Step 1.2 - Exporting Information"
    Foreach ($PC in $Equipment) {
        $ObjectDetail = [PSCustomObject][Ordered]@{
            'Name'            = $PC.Name
            'CanonicalName'   = $PC.CanonicalName
            'OS'              = $PC.OperatingSystem
            'OS Version'      = $PC.OperatingSystemVersion
            'Last Logon'      = $PC.lastLogonDate
            'Logon Count'     = $PC.logonCount
            'Bad Logon Count' = $PC.BadLogonCount
            'IP Address'      = $PC.IPv4Address
            'Enabled'         = if ($PC.Enabled) { 'enabled' } else { 'disabled' }
            'Date created'    = $PC.whenCreated
        }
        $ObjectDetail | Export-Csv $ExportFile -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion