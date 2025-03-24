#requires -runasadministrator
<# 
.DESCRIPTION 
    CleanUp Windows 10 from bloatware
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-18
#>
$Global:ErrorActionPreference = 'Stop'
$Options = @(
    #Packages
    'Microsoft.BingWeather'
    'Microsoft.Office.OneNote'
    'Microsoft.MicrosoftOfficeHub'
    'Microsoft.MicrosoftSolitaireCollection'
    'Microsoft.People'
    'Microsoft.SkypeApp'
    'Microsoft.WindowsMaps'
    'Microsoft.ZuneMusic'
    'Microsoft.ZuneVideo'
    #sponsors
    'BubbleWitch3Saga'
    'CandyCrush'
    'Dolby'
    'Duolingo-LearnLanguagesforFree'
    'EclipseManager'
    'Facebook'
    'Flipboard'
    'PandoraMediaInc'
    'Royal Revolt'
    'Spotify'
    'Sway'
    'Twitter'
    'Wunderlist'
    #$optionals
    'App.StepsRecorder'
    'Hello.Face.18967'
    'MathRecognizer'
    'Media.WindowsMediaPlayer'
    'OneCoreUAP.OneSync'
    'Print.Fax.Scan'
)
#Log Function
Function Write-Log {
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Message,
        [Parameter(Mandatory = $true)]
        [String]$Type
    )
    $Date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $Log = "$Date - $Type - $Message"
    $Log | Out-File -FilePath "C:\Temp\Log\$(Get-Date -Format 'yyyy-MM-dd').log" -Append -NoClobber -Encoding UTF8
}
# Export Location
Function CheckFilePath {
    If (Test-Path -Path 'C:\Temp\Log') {}Else {
        New-Item 'C:\Temp\Log' -ItemType Directory
    }
}
CheckFilePath

Try {
    Write-log -Message 'Cleaning up Windows' -Type 'Information'
    Foreach ($Option in $options) {
        If (Get-AppxPackage -Name $Option) {
            Get-AppxPackage -Name $Option | Remove-AppxPackage -ErrorAction SilentlyContinue
        } elseif (Get-AppxPackage | Where-Object Name -CMatch $Option) {
            Get-AppxPackage | Where-Object Name -CMatch $Option | Remove-AppxPackage -ErrorAction SilentlyContinue
        } ElseIf (Get-WindowsCapability -Online -LimitAccess | Where-Object { $_.Name -like $Option }) {
            Get-WindowsCapability -Online -LimitAccess | Where-Object { $_.Name -like $Option } | Remove-WindowsCapability -Online -ErrorAction SilentlyContinue
        }
    }
    Write-log -Message 'CleanUp complete' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to clenup' -Type 'Error'
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne 'n') {
    Start-Process 'https://github.com/llZektorll/Microsoft-PowerShell-Fastlane'
} else {
    break
}
