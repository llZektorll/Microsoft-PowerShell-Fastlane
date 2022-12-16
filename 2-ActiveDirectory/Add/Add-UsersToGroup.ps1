<# 
.SYNOPSIS
    Add users to Group
.DESCRIPTION 
    Add to Active Directory groups a single or multiple users from a CSV file
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2022-12-14 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    Information about PowerShell Modules to be required.
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
$logLocation = 'C:\Temp\'
$logFile = 'Add-UserToADGroup-log.txt'
$logFileLocation = "$($logLocation)$($logFile)"
$LogAppend = 1 # -> 1 = Retain previous log information | 2 = Delete old logs
# Group Section
$Group = 'MyGroup'
# Add User Section
$AddOption = 1 # -> 1 - Add single user | 2 - Add from CSV
$AddUser = 'MyUser@contoso.com'
$AddCsv = 'C:\Temp\ListOfUsers.csv'
$CsvDelimiter = ','
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
    Try {
        If ($AddOption -eq 1) {
            Write-Log "`t Step 2 - Adding single user"
            $User = Get-ADUser -Filter "$AddUser -eq '$_'" | Select-Object ObjectGUID
            If ($User) {
                Add-ADGroupMember -Identity $Group -Members $User
                Write-Log "`t Step 2.1 - User $($_) added to $($Group)"
            } Else {
                Write-Log "`t Step 2.2 - Unable to find user in Active Directory"
            }
        } ElseIf ($AddOption -eq 2) {
            Write-Log "`t Step 2 - Adding users from CSV file"
            $MyCSV = (Import-Csv -Path $AddCsv -Delimiter $CsvDelimiter -Header 'users').Name
            Foreach ($User in $MyCSV) {
                $Acc = Get-ADUser -Filter "$User -eq '$_'" | Select-Object ObjectGUID
                If ($Acc) {
                    Add-ADGroupMember -Identity $Group -Members $Acc
                    Write-Log "`t Step 2.1 - User $($User) added to $($Group)"
                } Else {
                    Write-Log "`t Step 2.1 - User $($User) not found in Active Directory"
                }
            }

        }
    } Catch {
        Write-Log "`t Error: $($_.Exception.Message)"
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
Write-Output "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion