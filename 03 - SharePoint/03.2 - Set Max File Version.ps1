<# 
.DESCRIPTION 
    Set max file version in all SharePoint sites
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
$Tenant_ID = '9023f0ij'
$Application_ID = 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1'
$Certificate_Thumb_Print = 'H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1'
$SPO_Sources = "https:\\mpfl.onmicrosoft.com"
#Version Variables
$Major_Versions = 25 #Max versions allowed
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

Try {
    Write-Log -Message "Connecting to SharePoint Online" -Type "Information"
    Connect-PnPOnline -Url $SPO_Sources -Tenant $Tenant_ID -ClientId $Application_ID -Thumbprint $Certificate_Thumb_Print
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to connect to SharePoint Online" -Type "Error"
}

Try {
    Write-Log -Message "Getting all sites" -Type "Information"
    $Sites = Get-PnPTenantSite
    Write-Log -Message "Retrieved $(($Sites).count) sites" -Type "Information"
    Write-Log -Message "Applying max version policy to all sites" -Type "Information"
    Foreach ($Site in $Sites) {
        $Site_Connection = Connect-PnPOnline -Url $Site.Url -Tenant $Tenant_ID -ClientId $Application_ID -Thumbprint $Certificate_Thumb_Print
        $Document_Libraries = Get-PnPList -Connection $Site_Connection | Where-Object { $_.BaseTemplate -eq 101 -and $_.Hidden -eq $false }
        Foreach ($Document_Librarie in $Document_Libraries) {
            If ($Document_Librarie.Title -eq 'Style Library') {
                Continue
            } ElseIf ($Document_Librarie.Title -eq 'Site Assets') {
                Continue
            } ElseIf ($Document_Librarie.versioning -eq $false) {
                Continue
            } Else {
                Write-Log -Message "Setting versioning policy to $($Major_Versions) for $($Document_Librarie.Title) in $($Site.Url)" -Type "Information"
                Set-PnPList -Identity $Document_Librarie -MajorVersions $Major_Versions -Connection $Site_Connection
            }
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

