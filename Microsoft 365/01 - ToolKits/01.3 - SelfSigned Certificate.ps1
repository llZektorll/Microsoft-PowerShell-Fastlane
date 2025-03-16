<# 
.DESCRIPTION 
    Create, install and export a certificate
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-10
#>
$Global:ErrorActionPreference = 'Stop'
#Certificate Variables
$Certificate_Name = 'MyCertificate'
$Key_Description = 'Certificate for Azure App Registration'
$File = 'My_Certificate.cer'
$Dates = 5 # Certificate valid for X years
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
    Write-Log -Message "Creating a self-signed certificate" -Type "Information"
    $Cert = New-SelfSignedCertificate -CertStoreLocation cert:\currentuser\my -Subject $Certificate_Name -KeyDescription $Key_Description -NotAfter (Get-Date).AddYears($Dates)
    $Cert.Thumbprint | Clip
    Export-Certificate -Cert $Cert -FilePath "C:\Temp\Export\$($File)" -Type CERT
    Write-Log -Message "Certificate created and exported" -Type "Success"
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-Log -Message "Failed to create a self-signed certificate" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

