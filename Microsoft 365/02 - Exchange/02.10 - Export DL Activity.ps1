<# 
.DESCRIPTION 
    Export DL activity
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

#Time Variables
$End_Date = Get-Date
$Start_Date = (Get-Date).AddDays(-180)

#Message Validation
$Email_Table = @{}
$Emails = $null
$Page = 1
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

Try{
    Write-log -Message "Connecting to Exchange Online" -Type "Information"
    Connect-ExchangeOnline -AppId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -Organization $Tenant
    Write-log -Message "Connected" -Type "Sucess"
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to connect" -Type "Error"
    Break
}

Try{
    Write-log -Message "Retriving messages sent" -Type "Information"
    Do{
        $Check_Message = (Get-MessageTrace -Status Expanded -PageSize 5000 -Page $Page -StartDate $Start_Date -EndDate $End_Date | Select-Object Received, RecipientAddress)
        $Page++
        $Emails += $Check_Message
    }Until($Check_Message -eq $null)    
    $Email_Table = ($Emails | Sort-Object RecipientAddress -Unique | Select-Object RecipientAddress, Received)
    Write-log -Message "Information read" -Type "Sucess"
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to get information" -Type "Error"
}

Try{
    Write-log -Message "Sorting and Exporting information" -Type "Information"
    $DLs_List = Get-DistributionGroup -ResultSize Unlimited
    Foreach($DL in $DLs_List){
        If($Email_Table -match $DL.PrimarySMTPAddress){
            $Export_DLs = [PSCustomObject][Ordered]@{
                Name = $DL.DisplayName
                SMTP = $DL.PrimarySMTPAddress
                Active = "Yes"
            }
        }Else{
            $Export_DLs = [PSCustomObject][Ordered]@{
                Name = $DL.DisplayName
                SMTP = $DL.PrimarySMTPAddress
                Active = "No"
            }
        }
        $Export_DLs | Export-Csv -Path "C:\Temp\Export\DL_Active.csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
    Write-log -Message "Information exported" -Type "Sucess"
}Catch{
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
