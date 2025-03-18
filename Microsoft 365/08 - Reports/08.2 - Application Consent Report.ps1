<# 
.DESCRIPTION 
    Export consent grants in Applications
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
# Connection Variables
$Tenant = 'MPFL.onmicrosoft.com'
$Application_ID = 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1'
$Certificate_Thumb_Print = 'H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1'
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
    If (Test-Path -Path 'C:\Temp\Export') {}Else {
        New-Item 'C:\Temp\Export' -ItemType Directory
    }
}
CheckFilePath

Try {
    Write-log -Message 'Connecting to Exchange Online' -Type 'Information'
    Connect-ExchangeOnline -AppId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -Organization $Tenant
    Write-log -Message 'Connected' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to connect' -Type 'Error'
    Break
}

Try {
    Write-log -Message 'Getting Application consents' -Type 'Information'
    $Search_Records = Search-UnifiedAuditLog -StartDate ((Get-Date).AddDays(-90)) -EndDate ((Get-Date).AddDays(1)) -ResultSize Unlimited -Operations 'Application Consent report'
    If ($Search_Records) {
        Foreach ($Record in $Search_Records) {
            $Audit_Data = $Record.Audit_Data | ConvertFrom-Json
            $Export_Records = [PSCustomObject]@{ 
                User         = $Audit_Data.UserId
                Date         = Get-Date ($Audit_Data.CreationTime) -Format yyyy-MM-dd
                ObjectId     = $Audit_Data.ObjectId
                AppId        = $Audit_Data.ObjectId.Split(';')[0]
                AdminConsent = $Audit_Data.ModifiedProperties | Where-Object { $_.Name -eq 'ConsentContext.IsAdminConsent' } | Select-Object -ExpandProperty NewValue
                ForAllUsers  = $Audit_Data.ModifiedProperties | Where-Object { $_.Name -eq 'ConsentContext.OnBehalfOfAll' } | Select-Object -ExpandProperty NewValue
                Tags         = $Audit_Data.ModifiedProperties | Where-Object { $_.Name -eq 'ConsentContext.Tags' } | Select-Object -ExpandProperty NewValue
                Details      = $Audit_Data.ExtendedProperties | Where-Object { $_.Name -eq 'additionalDetails' } | Select-Object -ExpandProperty Value 
            } 
            $Export_Records | Export-Csv -Path "C:\Temp\Export\Application_Consent_$(Get-Date -Format 'yyyy-MM-dd').csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
        }
    }
    Write-log -Message 'Information Exported' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to export information' -Type 'Error'
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne 'n') {
    Start-Process 'https://github.com/llZektorll/Microsoft-PowerShell-Fastlane'
} else {
    break
}
