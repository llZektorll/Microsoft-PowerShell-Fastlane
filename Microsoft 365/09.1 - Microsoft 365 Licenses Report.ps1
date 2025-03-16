<# 
.DESCRIPTION 
    Export all Microsoft 365 Licenses to a CSV file
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
$Tenant_ID = '9023f0ij'
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
    Write-log -Message "Cnnecting to Graph" -Type "Information"
    Connect-MgGraph -ClientId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -TenantId $Tenant_ID
    Write-log -Message "Connected to Graph" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to connect" -Type "Error"
    Break
}

Try {
    Write-log -Message "Gathering Licenses" -Type "Information"
    $Licenses = Get-MgSubscribedSku -All -Property * | Where-Object { $_.AppliesTo -eq "User" } | Sort-Object -Property ConsumedUnits -Descending
    Write-log -Message "Found $($Licenses.Count) types of licenses" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to get licenses" -Type "Error"
}

Try {
    Write-log -Message "Exporting information" -Type "Information"
    Foreach ($License in $Licenses) {
        $Export_Licenses = [PSCustomObject]@{
            TimeStamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            SkuId         = $License.SkuId
            License       = $License.SkuPartNumber
            Available     = $License.PrepaidUnits.Enabled
            ConsumedUnits = $License.ConsumedUnits
        }
        $Export_Licenses | Export-Csv -Path "C:\Temp\Export\Licenses-$(Get-Date -Format 'yyyy-MM-dd').csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
    Write-log -Message "Information Exported" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to export information" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

