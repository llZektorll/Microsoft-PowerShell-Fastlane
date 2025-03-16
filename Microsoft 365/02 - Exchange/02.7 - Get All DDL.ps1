<# 
.DESCRIPTION 
    Export all Dynamic Distribution Lists and their members to a CSV file
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-16
#>
If ([Net.SecurityProtocolType]::Tls12 -bor $False) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "`t Forced TLS 1.2 since its not server default"
}
$Global:ErrorActionPreference = 'Stop'
# Connection Variables
$Tenant = 'MPFL.onmicrosoft.com'
$Application_ID = 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1'
$Certificate_Thumb_Print = 'H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1'
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
        If (Test-Path -Path "C:\Temp\Export") {}Else {
            New-Item "C:\Temp\Export" -ItemType Directory
        }
}
CheckFilePath

Try {
    Write-log -Message "Connecting to Exchange Online" -Type "Information"
    Connect-ExchangeOnline -AppId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -Organization $Tenant 
    Write-log -Message "Connected" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to connect to Exchange Online" -Type "Error"
}

Try {
    Write-log -Message "Getting all DDl's" -Type "Information"
    $DDL_List = Get-DynamicDistributionGroup | Select-Object Name,PrimarySmtpAddress
    Write-log -Message "Found $($DDL_List) DDL's" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to find DDL's" -Type "Error"
}

Try {
    Write-log -Message "Sorting and Exporting information" -Type "Information"
    Foreach ($DLL in $DDL_List) {
        $Accounts = (Get-DynamicDistributionGroupMember -Identity $DLL.PrimarySmtpAddress -ResultSize unlimited).Count
        $Export_DDl = [PSCustomObject]@{
            Name               = $DLL.Name
            PrimarySmtpAddress = $DLL.PrimarySmtpAddress
            Members            = $Accounts
        }
        $Export_DDl | Export-Csv -Path "C:\Temp\Export\DDL_$(Get-Date -Format "yyyy-MM-dd").csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
    Write-log -Message "Information exported" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

