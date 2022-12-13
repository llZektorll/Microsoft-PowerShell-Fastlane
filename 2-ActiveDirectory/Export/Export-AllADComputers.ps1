<# 
.SYNOPSIS
    Export All AD Computers
.DESCRIPTION 
    Export all Computers registered on Active Directory
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2022-12-13 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    Connection to Active Directory or ruining the script directly on Active Directory
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
.Parameter ParameterName 
    All values are defined inside the variables region
#>

#region Ensure that TLS 1.2 is being used
If ([Net.SecurityProtocolType]::Tls12 -bor $False) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} Else {}
#endregion

#region Global Variables
# Log Section
$logLocation = 'C:\Temp\Logs\'
$logFile = 'Export_All_Computers_In_AD-log.txt'
$logFileLocation = "$($logLocation)$($logFile)"
$LogAppend = 1 # -> 1 = Retain previous log information | 2 = Delete old logs
# Export Section
$ExportPath = 'C:\Temp\Export\'
$ExportFile = 'Export_All_Computers_In_AD.csv'
$ExportFilePath = "$($ExportPath)$($ExportFile)"
$ExportAppend = 1 # -> 1 = Retain previous Export information | 2 = Delete old Export
# Exported Information Section
$EquipmentIs = '3' # -> 1 = Enabled | 2 = Disabled | 3 = Both
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
# OU Section
$OU = 'DC=contoso,DC=com'
#endregion

#region Functions
#File location
function CheckFilePath {
    # Log Location Section
    If (!(Test-Path -Path $logLocation)) {
        New-Item $logLocation -ItemType Directory
        Write-Log "`t Step 1.1 - File Path created for Logs"
    } Else {
        Write-Log "`t Step 1.1 - File Path already exists for Logs"
    }
    # Log File Section
    If ($LogAppend -eq 2) {
        If (Test-Path -Path $logFileLocation) {
            Remove-Item -Path $logFileLocation
            Write-Host "`t Step 1.2 - Old log file was DELETED"
        }
    } Else {
        Write-Host "`t Step 1.2 - Old log file was NOT deleted"
    }
    # Export Location Section
    If (!(Test-Path -Path $ExportPath)) {
        New-Item $ExportPath -ItemType Directory
        Write-Log "`t Step 1.3 - File Path created for the Export"
    } Else {
        Write-Log "`t Step 1.3 - File Path already exists for the Export"
    }
    # Export File Section
    If ($ExportAppend -eq 2) {
        If (Test-Path -Path $ExportFilePath) {
            Remove-Item -Path $ExportFilePath
            Write-Host "`t Step 1.4 - Old log file was Deleted"
        }
    } Else {
        Write-Host "`t Step 1.4 - Old export file was NOT deleted"
    }
}
#Save log of actions taken
function Write-Log {
    param (
        $Message,
        $ForegroundColor = 'White'
    )
    function TimeStamp { return '[{0:yyyy/MM/dd} {0:HH:mm:ss}]' -f (Get-Date) }

    "$(TimeStamp) $Message" | Tee-Object -FilePath $logFileLocation -Append | Write-Verbose
    Write-Host $Message -ForegroundColor $ForegroundColor
}
#endregion

#region Execution
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Checking file path's"
    CheckFilePath
    Write-Log "`t Step 2 - Colecting Information"
    Try {
        Write-Log "`t Step 2.1 - Colecting Computer Information"
        $Equipment = Get-ADComputer -Filter $EquipmentIs -SearchBase $OU -Properties $Properties | Select-Object $Properties
        Write-Log "`t Step 2.2 - Exporting Information"
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
            $ObjectDetail | Export-Csv $ExportFilePath -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
        }
        Write-Log "`t Step 2.3 - Export Compleated"
    } Catch {
        Write-Log "`t Error: $($_.Exception.Message)"
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
Write-Output "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion