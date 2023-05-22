<# 
.SYNOPSIS
    Export a list of all the Teams groups
.DESCRIPTION 
    Export a list with all Teams Groups to a CSV
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2023-05-09 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    Connection modules
        Exchange Online
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#Adding the configuration file to be ran 
. '.\Microsoft-PowerShell-Fastlane\1-ToolKits\TK0-Config.ps1'
#region Variables

#Export Files
$ExportPath = '.\Microsoft-PowerShell-Fastlane\Exports\'
$ExportFile = 'GetAllTeamsGroups.csv'
$ExportFilePath = "$($ExportPath)$($ExportFile)"

#endregion 

#region Execution
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==       Export All Teams Groups         =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Connecting to Exchange Online"
    Connect-EXO
    Write-Log "`t Step 2 - Colecting All Teams Groups"
    Try {
        $GoupsTeams = Get-UnifiedGroup -Filter { ResourceProvisioningOption -eq 'Team' } -ResultSize Unlimited
        $Teams = [PSCustomObject][Ordered]@{
            DisplayName        = $GoupsTeams.DisplayName
            SharePointSiteURL  = $GoupsTeams.SharePointSiteURL
            Alias              = $GoupsTeams.Alias
            PrimarySmtpAddress = $GoupsTeams.PrimarySmtpAddress
        }
        $Teams | Export-Csv $ExportFilePath -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    } Catch {
        Write-Log "`t Error: $($_.Exception.Message)"
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}

Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion