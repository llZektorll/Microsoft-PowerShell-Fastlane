<# 
.SYNOPSIS
    Add Users To Group
.DESCRIPTION 
    Add users to a Azure Active Directory Group
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
$logFile = 'Add-User_To_Group-log.txt'
$logFileLocation = "$($logLocation)$($logFile)"
$LogAppend = 1 # -> 1 = Retain previous log information | 2 = Delete old logs
# Group Section
$Group = 'My Group'
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
#Connect Azure Active Directory
Function Connect-AAD {
    $GetModuleAAD = Get-Module -ListAvailable -Name AzureAD
    If ($GetModuleAAD -ne 0) {
        Try {
            $GetmoduleAADUpdate = Read-Host 'Do you want to check if the module have updates? [Y] Yes [N] No'
            If ($GetmoduleAADUpdate -match '[yY]') {
                Write-Log "`t Checking and installing updates, please wait..."
                Install-Module -Name AzureAD -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to Azure Active Directory"
                Connect-AzureAD
            } Else {
                Write-Log "`t Connecting to Azure Active Directory without check for module updates"
                Connect-AzureAD
            }
        } Catch {
            Write-Log "`t Error Connecting to Azure Active Directory: $($_.Exception.Message)"
        }
    } Else {
        Try {
            Write-Log "`t Azure Active Directory module missing."
            $GetModuleAADInstall = Read-Host 'Do you want to install Azure Active Directory Module? [Y]Yes [N]No'
            If ($GetModuleAADInstall -match '[yY]') {
                Write-Log 'Installing Azure Active Directory Module, please wait ...'
                Install-Module -Name AzureAD -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to Azure Active Directory"
                Connect-AzureAD
            } Else {
                Write-Log "`t Unable to run the script without Azure Active Directory Module."
                Write-Log "`t Terminating the script. Press Enter to exit"
                Read-Host
                Exit
            }
        } Catch {
            Write-Log "`t Error Installing and Connecting to Azure Active Directory: $($_.Exception.Message)"
        }
    }
}
#endregion

#region Execution
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Checking file path's and files"
    CheckFilePath
    Write-Log "`t Step 2 - Connecting to Azure Active Directory"
    Connect-AAD
    Try {
        If ($AddOption -eq 1) {
            Try {
                Write-Log "`t Step 3 - Adding $($AddUser) to $($Group)"
                $GroupID = Get-AzureADGroup -Filter "displayName eq '$($Group)'" | Select-Object ObjectID
                $UserID = Get-User -Identity $AddUser | Select-Object ExternalDirectoryObjectId
                Add-AzureADGroupMember -ObjectId $GroupID -RefObjectId $UserID
                Write-Log "`t Step 3 -  The user $($AddUser) was added to $($Group)"
            } Catch {
                Write-Log "`t Error: $($_.Exception.Message)"
            }            
        } ElseIf ($AddOption -eq 2) {
            Write-Log "`t Step 3 - Adding the users from the CSV to the group $($Group)"
            Try {
                Write-Log "`t Step 3.1 - Importing CSV and gathering user information"
                $Users = (Import-Csv -Path $AddCsv -Delimiter $CsvDelimiter).name
                $GroupID = Get-AzureADGroup -Filter "displayName eq '$($Group)'" | Select-Object ObjectID
                Foreach ($User in $Users) {
                    $UserID = Get-User -Identity $User | Select-Object ExternalDirectoryObjectId
                    Add-AzureADGroupMember -ObjectId $GroupID -RefObjectId $UserID
                }
            } Catch {
                Write-Log "`t Error: $($_.Exception.Message)"
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