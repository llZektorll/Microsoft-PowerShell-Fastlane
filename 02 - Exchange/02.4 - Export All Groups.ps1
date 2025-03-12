<# 
.DESCRIPTION 
    Export all Groups and Group Owners
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-10
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

#Export Information
$Selections = @(
    'DisplayName',
    'SharePointSiteURL',
    'Alias',
    'PrimarySmtpAddress',
    'IsMembershipDynamic',
    'ResourceProvisioningOptions',
    'HiddenFromAddressListsEnabled',
    'GroupMemberCount',
    'ExpirationTime',
    'WhenCreated',
    'WhenChanged',
    'ExternalDirectoryObjectId'
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
    Write-Log -Message "Connecting to Exchange Online" -Type "Information"
    Connect-ExchangeOnline -AppId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -Organization $Tenant 
    Write-Log -Message "Connected to Exchange Online" -Type "Success"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-Log -Message "Connection to Exchange Online failed" -Type "Error"
}

Try {
    Write-Log -Message "Connecting to Azure AD"
    Connect-AzureAD -AppId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -Organization $Tenant
    Write-Log -Message "Connected to Azure AD" -Type "Success"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-Log -Message "Connection to Azure AD failed" -Type "Error"
}

Try {
    Write-Log -Message "Collecting all Groups" -Type "Information"
    $Groups = Get-UnifiedGroup -ResultSize Unlimited | Select-Object $Selections
    Write-Log -Message "Collected a total of $($Groups.count) groups" -Type "Success"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-Log -Message "Unable to collect groups" -Type "Error"
}
Try {
    Write-Log -Message "Collecting Group Owners" -Type "Information"
    Foreach ($Group in $Groups) {
        $GroupOwner = Get-AzureADGroupOwner -ObjectId "$($Group.ExternalDirectoryObjectId)" | Select-Object MailNickName
        if (($null -eq $GroupOwner) -or ($GroupOwner -eq "")) {
            Continue
        } else {
            $Data_To_Export = [PSCustomObject][Ordered]@{
                DisplayName                   = $Group.DisplayName
                SharePointSiteURL             = $Group.SharePointSiteURL
                Alias                         = $Group.Alias
                PrimarySmtpAddress            = $Group.PrimarySmtpAddress
                IsMembershipDynamic           = $Group.IsMembershipDynamic
                ResourceProvisioningOptions   = $Group.ResourceProvisioningOptions
                HiddenFromAddressListsEnabled = $Group.HiddenFromAddressListsEnabled
                GroupMemberCount              = $Group.GroupMemberCount
                ExpirationTime                = $Group.ExpirationTime
                WhenCreated                   = $Group.WhenCreated
                WhenChanged                   = $Group.WhenChanged
                Owner                         = $GroupOwner.MailNickName -join ('|')
            }
            $Data_To_Export | Export-Csv -Path "C:\Temp\Export\All_Groups_and_Owners.csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
        }
    }
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

