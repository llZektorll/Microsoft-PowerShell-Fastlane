<# 
.SYNOPSIS
    Certificate for Application
.DESCRIPTION 
    Generates a certificate to be configured on a Azure App registration to configure as a authentication method.
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2023-05-05 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    Connection modules include
        NA
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#Adding the configuration file to be ran 
. '.\Microsoft-PowerShell-Fastlane\1-ToolKits\TK0-Config.ps1'

#region Variables
#Certifica configurations
$CertificateName = 'MyCertificate'
$KeyDescription = 'Certificate for Azure App Registration'
$Dates = 1 # Value in Years
#Export Certificate
$ExportPath = '.\Microsoft-PowerShell-Fastlane\Exports\'
$ExportFile = 'MyCertificate.cer'
$ExportFilePath = "$($ExportPath)$($ExportFile)"
#endregion 

#region Execution
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==         Generate Certificate          =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Generating the certificate"
    $Cert = New-SelfSignedCertificate -CertStoreLocation cert:\currentuser\my -Subject $CertificateName -KeyDescription $KeyDescription -NotAfter (Get-Date).AddYears($Dates)
    $Cert.Thumbprint | clip
    Write-Log "`t Step 1.1 - Export certificate"
    Export-Certificate -Type CERT -Cert $Cert -FilePath $ExportFilePath
    Write-Log "`t Step 1.2 - Certificate exported successfully, closing the script"
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}

Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion