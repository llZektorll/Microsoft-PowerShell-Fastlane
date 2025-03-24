<# 
.DESCRIPTION 
    Get all subscribed SKUs and the Product display name to be exported
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-24
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
    Write-log -Message 'Connect Graph' -Type 'Information'
    Connect-MgGraph -ClientId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -TenantId $Tenant_ID
    Write-log -Message 'Connecter' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to connect' -Type 'Error'
}

Try {
    Write-log -Message 'Getting Subscribed SKUs and SKU List' -Type 'Information'
    $Subscribed_SKUs = Get-MgSubscribedSku | Select-Object -Property SkuID, SkuPartNumber, ConsumedUnits -ExpandProperty PrepaidUnits | Sort-Object -Descending -Property ConsumedUnits
    $SKU_List = Invoke-RestMethod -Method Get -Uri 'https://download.microsoft.com/download/e/3/e/e3e9faf2-f28b-490a-9ada-c6089a1fc5b0/Product%20names%20and%20service%20plan%20identifiers%20for%20licensing.csv' | ConvertFrom-Csv
    $SKU_List = $SKU_List | Select-Object -Property @{Name = 'skuId'; Expression = { ($_.GUID) } }, Product_Display_Name | Select-Object skuId,Product_Display_Name -Unique
    Write-log -Message 'Information sorted' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to get SKUs' -Type 'Error'
}

Try {
    Write-log -Message 'Sorting and exporting information' -Type 'Information'
    foreach ($SKU in $Subscribed_SKUs) {
        $Pre_Sort = ($SKU_List | Where-Object { $_.skuId -eq $SKU.SkuId } | Sort-Object Product_Display_Name -Unique).Product_Display_Name
        $Export_SKUs = [pscustomobject]@{
            ProductDisplayName = $Pre_Sort
            ConsumedUnits      = $SKU.ConsumedUnits
            Enabled            = $SKU.Enabled
            LockedOut          = $SKU.LockedOut
            Suspended          = $SKU.Suspended
            Warning            = $SKU.Warning
            Available          = ($SKU.Enabled - $SKU.ConsumedUnits)
            SkuID              = $SKU.SkuId
            SkuPartNumber      = $SKU.SkuPartNumber
        }
        $Export_SKUs | Export-Csv -Path "C:\Temp\Export\ExportSKU_$(Get-Date -Format 'yyyy-MM-dd').csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
    Write-log -Message 'Expoted information' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to Export Information' -Type 'Error'
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne 'n') {
    Start-Process 'https://github.com/llZektorll/Microsoft-PowerShell-Fastlane'
} else {
    break
}
