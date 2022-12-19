<# 
.SYNOPSIS
    Remove Pre-Installed apps in Windows
.DESCRIPTION 
    Removed all pre installed applications that came with Windows
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2022-12-14 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    
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
$logFile = 'Remove-PreInstalledApps-log.txt'
$logFileLocation = "$($logLocation)$($logFile)"
$LogAppend = 1 # -> 1 = Retain previous log information | 2 = Delete old logs
# Apps Section
$Apps = @(
    # default Windows 10 apps
    'Microsoft.549981C3F5F10' #Cortana
    'Microsoft.3DBuilder'
    'Microsoft.Appconnector'
    'Microsoft.BingFinance'
    'Microsoft.BingNews'
    'Microsoft.BingSports'
    'Microsoft.BingTranslator'
    'Microsoft.BingWeather'
    'Microsoft.FreshPaint'
    'Microsoft.GamingServices'
    'Microsoft.Microsoft3DViewer'
    'Microsoft.MicrosoftOfficeHub'
    'Microsoft.MicrosoftPowerBIForWindows'
    'Microsoft.MicrosoftSolitaireCollection'
    'Microsoft.MicrosoftStickyNotes'
    'Microsoft.MinecraftUWP'
    'Microsoft.NetworkSpeedTest'
    'Microsoft.Office.OneNote'
    'Microsoft.People'
    'Microsoft.Print3D'
    'Microsoft.SkypeApp'
    'Microsoft.Wallet'
    #"Microsoft.Windows.Photos"
    'Microsoft.WindowsAlarms'
    #"Microsoft.WindowsCalculator"
    'Microsoft.WindowsCamera'
    'microsoft.windowscommunicationsapps'
    'Microsoft.WindowsMaps'
    'Microsoft.WindowsPhone'
    'Microsoft.WindowsSoundRecorder'
    'Microsoft.WindowsStore'
    'Microsoft.Xbox.TCUI'
    'Microsoft.XboxApp'
    'Microsoft.XboxGameOverlay'
    'Microsoft.XboxGamingOverlay'
    'Microsoft.XboxSpeechToTextOverlay'
    'Microsoft.YourPhone'
    'Microsoft.ZuneMusic'
    'Microsoft.ZuneVideo'
    'Microsoft.CommsPhone'
    'Microsoft.ConnectivityStore'
    'Microsoft.GetHelp'
    'Microsoft.Getstarted'
    'Microsoft.Messaging'
    'Microsoft.Office.Sway'
    'Microsoft.OneConnect'
    'Microsoft.WindowsFeedbackHub'
    # Creators Update 
    'Microsoft.Microsoft3DViewer'
    'Microsoft.MSPaint'
    'Microsoft.BingFoodAndDrink'
    'Microsoft.BingHealthAndFitness'
    'Microsoft.BingTravel'
    'Microsoft.WindowsReadingList'
    'Microsoft.MixedReality.Portal'
    'Microsoft.ScreenSketch'
    'Microsoft.XboxGamingOverlay'
    'Microsoft.YourPhone'
    # non-Microsoft
    '2FE3CB00.PicsArt-PhotoStudio'
    '46928bounde.EclipseManager'
    '4DF9E0F8.Netflix'
    '613EBCEA.PolarrPhotoEditorAcademicEdition'
    '6Wunderkinder.Wunderlist'
    '7EE7776C.LinkedInforWindows'
    '89006A2E.AutodeskSketchBook'
    '9E2F88E3.Twitter'
    'A278AB0D.DisneyMagicKingdoms'
    'A278AB0D.MarchofEmpires'
    'ActiproSoftwareLLC.562882FEEB491'
    'CAF9E577.Plex'  
    'ClearChannelRadioDigital.iHeartRadio'
    'D52A8D61.FarmVille2CountryEscape'
    'D5EA27B7.Duolingo-LearnLanguagesforFree'
    'DB6EA5DB.CyberLinkMediaSuiteEssentials'
    'DolbyLaboratories.DolbyAccess'
    'DolbyLaboratories.DolbyAccess'
    'Drawboard.DrawboardPDF'
    'Facebook.Facebook'
    'Fitbit.FitbitCoach'
    'Flipboard.Flipboard'
    'GAMELOFTSA.Asphalt8Airborne'
    'KeeperSecurityInc.Keeper'
    'NORDCURRENT.COOKINGFEVER'
    'PandoraMediaInc.29680B314EFC2'
    'Playtika.CaesarsSlotsFreeCasino'
    'ShazamEntertainmentLtd.Shazam'
    'SlingTVLLC.SlingTV'
    'SpotifyAB.SpotifyMusic'
    'TheNewYorkTimes.NYTCrossword'
    'ThumbmunkeysLtd.PhototasticCollage'
    'TuneIn.TuneInRadio'
    'WinZipComputing.WinZipUniversal'
    'XINGAG.XING'
    'flaregamesGmbH.RoyalRevolt2'
    'king.com.*'
    'king.com.BubbleWitch3Saga'
    'king.com.CandyCrushSaga'
    'king.com.CandyCrushSodaSaga'
    'Microsoft.Advertising.Xaml'
)
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
        Write-Log "`t Step 2 - Removing Apps"
        Foreach ($App in $Apps) {
            Write-Log "`t Step 2.1 - Removing application $($App)"
            $AppVersion = (Get-AppxPackage -Name $App).Version
            If ($AppVersion) {
                Get-AppxPackage -Name $App -AllUsers | Remove-AppxPackage -AllUsers
            }
            #Prevents new local user to have the applications installed
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $App | Remove-AppxProvisionedPackage -Online
            #clenup space used by the apps
            $AppPath = "$Env:LOCALAPPDATA\Packages\$App*"
            Remove-Item $AppPath -Recurse -Force -ErrorAction 0
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