<# 
.SYNOPSIS
    Module Installation
.DESCRIPTION 
    Automatic installation of all modules for to manage Microsoft 365
.NOTES 
    Vertsion:   2.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2024-01-27 (YYYY-MM-DD)
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#region Variables
$Global:ErrorActionPreference = 'Stop'
$RootLocation = 'C:\Temp'
$LogFile = "$($RootLocation)\Logs\Log$(Get-Date -Format 'yyyyMM').txt"

#Modules to Install
$Modules = @(
    'AzureAD',
    'ExchangeOnlineManagement',
    'Microsoft.Graph',
    'Microsoft.Online.SharePoint.PowerShell',
    'MicrosoftTeams',
    'PNP.PowerShell',
    'MicrosoftPowerBIMgmt'
)
#endregion 

#region Functions

#region Check Log File Location
Function CheckFilePath {
    If (Test-Path -Path "$($RootLocation)\Logs") {}Else {
        New-Item "$($RootLocation)\Logs" -ItemType Directory
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
Write-Log "`t ==            TK1 New Machine            =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Installing Modules"
    $Step = 1
    Foreach ($Module in $Modules) {
        Try {
            Install-Module -Name $Module -Confirm:$False -Force
            Write-Log "`t Step 1.$Step - Module $Module installed"
            $Step++
        } Catch {
            Write-Log "`t Step 1.1 - Unable to install $Module Module"
            Write-Log "`t Error: $($_.Exception.Message)"
        }
    }
    Write-Log "`t Step 1.$($Step) - All Modules installed"
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}

Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion