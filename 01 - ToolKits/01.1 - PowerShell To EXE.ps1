<# 
.DESCRIPTION 
    Install and compilarion of PowerShell scripts into a Windows Application
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-02-25
#>
$Global:ErrorActionPreference = 'Stop'
$ModuleName = "ps2exe"
$Source = "C:\Temp\Script.ps1"
$Destination = "C:\Temp\Script.exe"
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
    Write-Log -Message "Check installation of module ps2exe" -Type "Information"
    if (Get-Module -ListAvailable -Name $ModuleName) {
        Write-Log -Message "Module already installed" -Type "Success"
    } else {
        Write-Log -Message "Installing module ps2exe" -Type "Information"
        Install-Module -Name ps2exe -Confirm:$false -Force
        Write-Log -Message "Installation of module ps2exe" -Type "Success"
    }
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to install the module" -Type "Error"
}
Try{
    Write-Log -Message "Convert of PowerShell to EXE" -Type "Information"
    Invoke-PS2EXE $Source $Destination
    Write-Log -Message "Conversion performed" -Type "Success"
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to convert the script to a EXE" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

