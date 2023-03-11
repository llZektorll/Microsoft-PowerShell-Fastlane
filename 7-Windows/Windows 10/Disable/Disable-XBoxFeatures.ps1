<# 
.SYNOPSIS
    Disable EXBox features
.DESCRIPTION 
    Disable all features associated with Xbox services
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2022-12-19 (YYYY-MM-DD)
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
$logFile = 'Disable-XBoxFeatures-log.txt'
$logFileLocation = "$($logLocation)$($logFile)"
$LogAppend = 1 # -> 1 = Retain previous log information | 2 = Delete old logs
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
    Write-Log "`t Step 2 - Disabling Xbox features"
    Get-AppxPackage 'Microsoft.XboxApp' | Remove-AppxPackage
    Get-AppxPackage 'Microsoft.XboxIdentityProvider' | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxPackage 'Microsoft.XboxSpeechToTextOverlay' | Remove-AppxPackage
    Get-AppxPackage 'Microsoft.XboxGameOverlay' | Remove-AppxPackage
    Get-AppxPackage 'Microsoft.XboxGamingOverlay' | Remove-AppxPackage
    Get-AppxPackage 'Microsoft.Xbox.TCUI' | Remove-AppxPackage
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AutoGameModeEnabled' -Type DWord -Value 0
    Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Type DWord -Value 0
    If (!(Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR')) {
        New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' | Out-Null
    }
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' -Name 'AllowGameDVR' -Type DWord -Value 0
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
Write-Output "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion