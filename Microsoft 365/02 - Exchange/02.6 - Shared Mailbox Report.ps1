<# 
.DESCRIPTION 
    Export the statistics of all Shared Mailbox inclluding license and archive if enabled
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
$Tenant_ID = '9023f0ij'
$Application_ID = 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1'
$Certificate_Thumb_Print = 'H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1'

$Mailbox_Filter = @(
    'ExternalDirectoryObjectId',
    'Alias',
    'UserPrincipalName',
    'MailboxPlan',
    'RecipientTypeDetails',
    'ArchiveStatus',
    'DeliverToMailboxAndForward',
    'ForwardingSmtpAddress',
    'WhenCreated',
    'IsMailboxEnabled'
)
$Mailbox_Statistics_Filter = @(
    'LasLogonTime',
    'ItemCount',
    'TotalDeletedItemSize',
    'TotalItemSize'
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
        If (Test-Path -Path "C:\Temp\Export") {}Else {
            New-Item "C:\Temp\Export" -ItemType Directory
        }
}
CheckFilePath

Try {
    Write-log -Message "Connecting to Exchange Online" -Type "Information"
    Connect-ExchangeOnline -AppId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -Organization $Tenant 
    Write-log -Message "Connected to Exchange Online" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to connect to Exchange Online" -Type "Error"
    Break
}
Try {
    Write-log -Message "Connecting to Graph" -Type "Information"
    Connect-MgGraph -ClientId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -TenantId $Tenant_ID
    Write-log -Message "Connected to Graph" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to connect to Graph" -Type "Error"
    Break
}
Try {
    Write-log -Message "Gathering all Shared Mailbox" -Type "Information"
    $Shared_Mailbox_List = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.RecipientTypeDetails -ne 'UserMailbox' -and $_.RecipientTypeDetails -ne 'SchedulingMailbox' } | Select-Object $Mailbox_Filter
    Write-log -Message "Found $($Shared_Mailbox_List.Count) Shared Mailbox" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to gather Shared Mailbox" -Type "Error"
}

Try {
    Write-log -Message "Exporting Informaiton" -Type "Information"
    Foreach ($Mailbox in $Shared_Mailbox_List) {
        $Mailbox_License = Get-MgUserLicenseDetail -UserId $Mailbox.ExternalDirectoryObjectId
        $Mailbox_Statistics = Get-MailboxFolderStatistics -Identity $Mailbox.UserPrincipalName -IncludeOldestAndNewestItems
        Try {
            $Last_Email = New-TimeSpan -Start $($Mailbox_Statistics.NewestItemReceivedDate | Sort-Object -Descending | Select-Object -First 1) -End $(Get-Date)
        } Catch {
            $Last_Email = ""
        }
        $Mailbox_Update = Get-MailboxStatistics -Identity $Mailbox.UserPrincipalName | Select-Object $Mailbox_Statistics_Filter

        If ($Mailbox.ArchiveStatus -match 'Active') {
            $Archive_Statistics = Get-MailboxStatistics -Identity $Mailbox.UserPrincipalName -Archive | Select-Object TotalItemSize, ArchiveQuota
        }
        $Export_Shared_Mailbox = [PSCustomObject][Ordered]@{
            Update                     = Get-Date -Format 'yyyy-MM-dd'
            DeliverToMailboxAndForward = $Mailbox.DeliverToMailboxAndForward
            ForwardingSmtpAddress      = $Mailbox.ForwardingSmtpAddress
            IsMailboxEnabled           = $Mailbox.IsMailboxEnabled
            UserPrincipalName          = $Mailbox.UserPrincipalName
            MailboxPlan                = $Mailbox_License.SkuId
            ArchiveStatus              = $Mailbox.ArchiveStatus
            Alias                      = $Mailbox.Alias
            CustomAttribute12          = $Mailbox.CustomAttribute12
            CustomAttribute3           = $Mailbox.CustomAttribute3
            ExternalDirectoryObjectId  = $Mailbox.ExternalDirectoryObjectId
            RecipientTypeDetails       = $Mailbox.RecipientTypeDetails
            WhenCreated                = $Mailbox.WhenCreated
            LasLogonTime               = $Mailbox_Update.LasLogonTime
            ItemCount                  = $Mailbox_Update.ItemCount
            TotalDeletedItemSize       = $([math]::round( ([decimal](($Mailbox_Update = Get-Date -Format 'yyyy-MM-dd'.TotalDeletedItemSize -replace '[0-9\.]+ [A-Z]* \(([0-9,]+) bytes\)',"`$1") -replace ',','') / 1GB),2))
            TotalItemSize              = $([math]::round( ([decimal](($Mailbox_Update.TotalItemSize -replace '[0-9\.]+ [A-Z]* \(([0-9,]+) bytes\)',"`$1") -replace ',','') / 1GB),2))
            ArchiveTotalItemSize       = $([math]::round( ([decimal](($Archive_Statistics.TotalItemSize -replace '[0-9\.]+ [A-Z]* \(([0-9,]+) bytes\)',"`$1") -replace ',','') / 1GB),2))
            ArchiveQuota               = $([math]::round( ([decimal](($Archive_Statistics.ArchiveQuota -replace '[0-9\.]+ [A-Z]* \(([0-9,]+) bytes\)',"`$1") -replace ',','') / 1GB),2))
            LastEmailInDays            = $Last_Email.Days
        }
        $Export_Shared_Mailbox | Export-Csv -Path "C:\Temp\Export\ShareMailboxStatistics.csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }

    Write-log -Message "Information exported" -Type "Sucess"
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

