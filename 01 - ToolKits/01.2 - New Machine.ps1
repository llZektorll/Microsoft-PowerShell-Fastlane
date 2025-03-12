<# 
.DESCRIPTION 
    Install all modules requiered for Microsoft 365 and PowerBI
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-10
#>
$Global:ErrorActionPreference = 'Stop'
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
#Log Function
Function Write-Log{
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Message,
        [Parameter(Mandatory=$true)]
        [String]$Type
    )
    $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Log = "$Date - $Type - $Message"
    $Log | Out-File -FilePath "C:\Temp\Log\$(Get-Date -Format "yyyy-MM-dd").log" -Append -NoClobber -Encoding UTF8
}
# Export Location
Function CheckFilePath {
        If (Test-Path -Path "C:\Temp\Log") {}Else {
            New-Item "C:\Temp\Log" -ItemType Directory
        }
}
CheckFilePath

Try{
    Write-Log -Message "Install required modules" -Type "Information"
    #Modules to Install
    Foreach($Module in $Modules){
        Try{
            Install-Module -Name $Module -Confirm:$false -Force
            Write-Log -Message "Module $($Module) installed" -Type "Success"
        }Catch{
            Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
            Write-Log -Message "Unable to install $($Module)" -Type "Error"
        }
    }
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

