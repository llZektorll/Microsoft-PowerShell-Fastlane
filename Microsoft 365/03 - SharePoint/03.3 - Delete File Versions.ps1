<# 
.DESCRIPTION 
    Delete all file version from all sites. 
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
    Write-Log -Message "Connecting to SharePoint Online" -Type "Information"
    Connect-PnPOnline -Url $SPO_Sources -Tenant $Tenant_ID -ClientId $Application_ID -Thumbprint $Certificate_Thumb_Print
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to connect to SharePoint Online" -Type "Error"
}
Try{
    Write-Log -Message "Getting all sites from SharePoint Online" -Type "Information"
    $Sites = Get-PnPTenantSite
    Write-Log -Message "Sites found: $($Sites.Count)" -Type "Information"
    Foreach($Site in $Sites){
        Connect-PnPOnline -Url $Site.Url -Tenant $TenantId -ClientId $Application_ID -Thumbprint $CertThumbprint
        $Contxt = Get-PnPContext
        $Document_Libraries = Get-PnPList | Where-Object { $_.BaseType -eq 'DocumentLibrary' -and $_.Hidden -eq $false }
        $i = 1
        $Document_Lib = $Document_Libraries.Count
        Foreach($Library in $Document_Libraries){
            Write-Progress -Activity 'Cleaning Versions' -Status "Current count: $($i) of $($Document_Lib) Document Libraries" -PercentComplete (($i / $Document_Lib) * 100)
            $List_Items = Get-PnPListItem -List $Library -PageSize 2000 | Where-Object { $_.FileSystemObjectType -eq 'File' }
            Foreach ($Item in $List_Items) {
                #Get File Versions
                $File = $Item.File
                $Versions = $File.Versions
                $Contxt.Load($File)
                $Contxt.Load($Versions)
                $Contxt.ExecuteQuery()
                $VersionsCount = $Versions.Count
                If ($VersionsCount -gt 0) {
                    $Versions.DeleteAll()
                    Invoke-PnPQuery
                }
            }
            $i++
        }
    }
    Write-Log -Message "All sites processed" -Type "Success"
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-Log -Message "Unable to process all sites" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

