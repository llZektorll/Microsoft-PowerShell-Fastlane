<# 
.SYNOPSIS
    Export All AD Computers
.DESCRIPTION 
    Export all Computers registered on Active Directory
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2023-05-09 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    Connection to Active Directory or ruining the script directly on Active Directory
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
.Parameter ParameterName 
    All values are defined inside the variables region
#>
#Adding the configuration file to be ran 
. '.\Microsoft-PowerShell-Fastlane\1-ToolKits\TK0-Config.ps1'
#region Variables
# Export Section
$ExportPath = '.\Microsoft-PowerShell-Fastlane\Exports\'
$ExportFile = 'ExportAllADComputers.csv'
$ExportFilePath = "$($ExportPath)$($ExportFile)"
# Exported Information Section
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

#region Execution
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==         Export Computer in AD         =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Colecting Information"
    Try {
        Write-Log "`t Step 1.1 - Colecting Computer Information"
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
            $ObjectDetail | Export-Csv $ExportFilePath -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
        }
        Write-Log "`t Step 1.3 - Export Compleated"
    } Catch {
        Write-Log "`t Error: $($_.Exception.Message)"
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion