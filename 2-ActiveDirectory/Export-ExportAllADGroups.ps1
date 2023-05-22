<# 
.SYNOPSIS
    Export All AD Groups
.DESCRIPTION 
    Export all Groups in Active Directory
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
$ExportFile = 'ExportAllADGroups.csv'
$ExportFilePath = "$($ExportPath)$($ExportFile)"
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

#region Execution
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==          Export Groups in AD          =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Colecting Information"
    Try {
        Write-Log "`t Step 1.1 - Coleting all Groups"
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