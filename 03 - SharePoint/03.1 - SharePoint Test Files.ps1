<# 
.DESCRIPTION 
    Upload files to a SharePoint site and add versions for testing.
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
#Files and versions count
$Version_Count = 100 # Number of versions for each file
$File1 = 'C:\Temp\TheFile1.ps1'
$File2 = 'C:\Temp\TheFile2.docx'
$File3 = 'C:\Temp\TheFile3.xlsx'
$File4 = 'C:\Temp\TheFile4.txt'
$File5 = 'C:\Temp\TheFile5.csv'
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

Try{
    Write-Log -Message "Connecting to SharePoint Online" -Type "Information"
    Connect-PnPOnline -Url $SPO_Sources -Tenant $Tenant_ID -ClientId $Application_ID -Thumbprint $Certificate_Thumb_Print
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to connect to SharePoint Online" -Type "Error"
}

Try{
    Write-Log -Message "Adding files to SharePoint Online" -Type "Information"
    # Add files to SharePoint Online
    $i = 0
    While($i -ne $Version_Count){
        Add-PnPFile -Path $File1 -Folder 'Shared Documents/Test_1'
        Add-PnPFile -Path $File2 -Folder 'Shared Documents/Test_1'
        Add-PnPFile -Path $File3 -Folder 'Shared Documents/Test_1'
        Add-PnPFile -Path $File4 -Folder 'Shared Documents/Test_1'
        Add-PnPFile -Path $File5 -Folder 'Shared Documents/Test_1'
        $i++
    }
    Write-Log -Message "Files added to SharePoint Online" -Type "Success"
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-Log -Message "Unable to add files to SharePoint Online" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

