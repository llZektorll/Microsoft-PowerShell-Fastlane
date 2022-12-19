<# 
.SYNOPSIS
    Remove third party apps
.DESCRIPTION 
    Remove third party apps pre installed on windows
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
$logFile = 'Remove-ThirdPartyApps-log.txt'
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
    Write-Log "`t Step 2 - Uninstalling default third party applications"
    Get-AppxPackage '2414FC7A.Viber' | Remove-AppxPackage
    Get-AppxPackage '41038Axilesoft.ACGMediaPlayer' | Remove-AppxPackage
    Get-AppxPackage '46928bounde.EclipseManager' | Remove-AppxPackage
    Get-AppxPackage '4DF9E0F8.Netflix' | Remove-AppxPackage
    Get-AppxPackage '64885BlueEdge.OneCalendar' | Remove-AppxPackage
    Get-AppxPackage '7EE7776C.LinkedInforWindows' | Remove-AppxPackage
    Get-AppxPackage '828B5831.HiddenCityMysteryofShadows' | Remove-AppxPackage
    Get-AppxPackage '89006A2E.AutodeskSketchBook' | Remove-AppxPackage
    Get-AppxPackage '9E2F88E3.Twitter' | Remove-AppxPackage
    Get-AppxPackage 'A278AB0D.DisneyMagicKingdoms' | Remove-AppxPackage
    Get-AppxPackage 'A278AB0D.DragonManiaLegends' | Remove-AppxPackage
    Get-AppxPackage 'A278AB0D.MarchofEmpires' | Remove-AppxPackage
    Get-AppxPackage 'ActiproSoftwareLLC.562882FEEB491' | Remove-AppxPackage
    Get-AppxPackage 'AD2F1837.GettingStartedwithWindows8' | Remove-AppxPackage
    Get-AppxPackage 'AD2F1837.HPJumpStart' | Remove-AppxPackage
    Get-AppxPackage 'AD2F1837.HPRegistration' | Remove-AppxPackage
    Get-AppxPackage 'AdobeSystemsIncorporated.AdobePhotoshopExpress' | Remove-AppxPackage
    Get-AppxPackage 'Amazon.com.Amazon' | Remove-AppxPackage
    Get-AppxPackage 'C27EB4BA.DropboxOEM' | Remove-AppxPackage
    Get-AppxPackage 'CAF9E577.Plex' | Remove-AppxPackage
    Get-AppxPackage 'CyberLinkCorp.hs.PowerMediaPlayer14forHPConsumerPC' | Remove-AppxPackage
    Get-AppxPackage 'D52A8D61.FarmVille2CountryEscape' | Remove-AppxPackage
    Get-AppxPackage 'D5EA27B7.Duolingo-LearnLanguagesforFree' | Remove-AppxPackage
    Get-AppxPackage 'DB6EA5DB.CyberLinkMediaSuiteEssentials' | Remove-AppxPackage
    Get-AppxPackage 'DolbyLaboratories.DolbyAccess' | Remove-AppxPackage
    Get-AppxPackage 'Drawboard.DrawboardPDF' | Remove-AppxPackage
    Get-AppxPackage 'Facebook.Facebook' | Remove-AppxPackage
    Get-AppxPackage 'Fitbit.FitbitCoach' | Remove-AppxPackage
    Get-AppxPackage 'flaregamesGmbH.RoyalRevolt2' | Remove-AppxPackage
    Get-AppxPackage 'GAMELOFTSA.Asphalt8Airborne' | Remove-AppxPackage
    Get-AppxPackage 'KeeperSecurityInc.Keeper' | Remove-AppxPackage
    Get-AppxPackage 'king.com.BubbleWitch3Saga' | Remove-AppxPackage
    Get-AppxPackage 'king.com.CandyCrushFriends' | Remove-AppxPackage
    Get-AppxPackage 'king.com.CandyCrushSaga' | Remove-AppxPackage
    Get-AppxPackage 'king.com.CandyCrushSodaSaga' | Remove-AppxPackage
    Get-AppxPackage 'king.com.FarmHeroesSaga' | Remove-AppxPackage
    Get-AppxPackage 'Nordcurrent.CookingFever' | Remove-AppxPackage
    Get-AppxPackage 'PandoraMediaInc.29680B314EFC2' | Remove-AppxPackage
    Get-AppxPackage 'PricelinePartnerNetwork.Booking.comBigsavingsonhot' | Remove-AppxPackage
    Get-AppxPackage 'SpotifyAB.SpotifyMusic' | Remove-AppxPackage
    Get-AppxPackage 'ThumbmunkeysLtd.PhototasticCollage' | Remove-AppxPackage
    Get-AppxPackage 'WinZipComputing.WinZipUniversal' | Remove-AppxPackage
    Get-AppxPackage 'XINGAG.XING' | Remove-AppxPackage
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
Write-Output "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion