#requires -runasadministrator
<# 
.DESCRIPTION 
    Remove Copilot from Windows 10
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-18
#>
If ([Net.SecurityProtocolType]::Tls12 -bor $False) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "`t Forced TLS 1.2 since its not server default"
}
$Global:ErrorActionPreference = 'Stop'

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
    Write-log -Message 'Removing Copilot' -Type 'Information'
    Get-AppxPackage -AllUsers | Where-Object { $_.Name -Like '*Microsoft.Copilot*' } | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Write-log -Message 'Removed' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to remove' -Type 'Error'
}

$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne 'n') {
    Start-Process 'https://github.com/llZektorll/Microsoft-PowerShell-Fastlane'
} else {
    break
}
