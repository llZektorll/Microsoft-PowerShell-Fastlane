<# 
.SYNOPSIS
    Export All AD Groups
.DESCRIPTION 
    Export all Groups in Active Directory
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
$logFile = 'Template-log.txt'
$logFileLocation = "$($logLocation)$($logFile)"
$LogAppend = 1 # -> 1 = Retain previous log information | 2 = Delete old logs
# Export Section
$ExportPath = 'C:\Temp\Export\'
$ExportFile = 'Export_Template-log.csv'
$ExportFilePath = "$($ExportPath)$($ExportFile)"
$ExportAppend = 1 # -> 1 = Retain previous Export information | 2 = Delete old Export
# OU Section
$OU = 'DC=contoso,DC=com'
# Properties to Export Section
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
    Write-Log "`t Step 1 - Checking file path's and files"
    CheckFilePath
    Write-Log "`t Step 2 - Colecting Information"
    Try {
        Write-Log "`t Step 2.1 - Coleting all Groups"
        $Groups = Get-ADGroup -SearchBase $OU -Filter * -Properties $Properties | Select-Object $Properties
        Write-Log "`t Step 2.2 - Exporting Information"
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