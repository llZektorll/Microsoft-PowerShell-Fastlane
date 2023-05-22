<# 
.SYNOPSIS
    Add users to AD Group
.DESCRIPTION 
    Add to Active Directory groups multiple users from a CSV file
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2023-05-09 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    Connection modules include 
        Active Directory
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#Adding the configuration file to be ran 
. '.\Microsoft-PowerShell-Fastlane\1-ToolKits\TK0-Config.ps1'

#region Variables
#Group Information
$Group = 'MyGroup'
#Users Information
$MyList = '.\Microsoft-PowerShell-Fastlane\Import\User.csv' #Ensure the column for the UPN is named "User"
$CsvDelimiter = ','
#endregion 


#region Execution
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==         Add User To AD Groud          =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Adding users to the Group: $($Group)"
    Try {
        $MyCSV = (Import-Csv -Path $MyList -Delimiter $CsvDelimiter).User
        $i = 1
        Foreach ($Account in $MyCSV) {
            $Acc = Get-ADUser -Filter "$User -eq '$_" | Select-Object ObjectGUID
            If ($Acc) {
                Add-ADGroupMember -Identity $Group -Members $Acc
                Write-Log "`t Step 1.1 - User: $($Acc) added to thr group $($Group)"
            } Else {
                Write-Log "`t Error 1.1 - Unable to find or add the user"
                Write-Log "`t Error 1.1 - User on Line $($i) in the CSV"
            }
            $i++
        }
    } Catch {
        Write-Log "`t Error: $($_.Exception.Message)"
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}

Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion