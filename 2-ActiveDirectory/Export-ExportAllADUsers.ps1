<# 
.SYNOPSIS
    Export All AD Users
.DESCRIPTION 
    Export all users on Active Directory
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
$ExportPath = 'C:\Temp\Export\'
$ExportFile = 'Export_All_AD_Users-log.csv'
$ExportFilePath = "$($ExportPath)$($ExportFile)"
# OU Section
$OU = 'DC=contoso,DC=com'
# Filter Section
$Properties = @(
    'Name',
    'UserPrincipalName',
    'distinguishedName'
    'mail',
    'extensionAttribute2',
    'extensionAttribute3',
    'extensionAttribute5'
)
#endregion

#region Execution
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==         Export All User in AD         =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Colecting Information"
    Try {
        Write-Log "`t Step 1.1 - Colecting Users"
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
                $ObjectDetail | Export-Csv $ExportFilePath -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
            }
            Write-Log "`t Step 1.3 - Export compleated"
        } Catch {
            Write-Log "`t Error: $($_.Exception.Message)"
        }
    } Catch {
        Write-Log "`t Error: $($_.Exception.Message)"
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion