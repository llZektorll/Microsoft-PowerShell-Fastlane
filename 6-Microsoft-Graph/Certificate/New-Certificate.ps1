<# 
.SYNOPSIS
    Generate a certificate for Microsoft Graph Application
.DESCRIPTION 
    The script will generate a self assigned certificate to use as authentication on Microsoft Graph
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2023-03-10 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    None
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>

#region Ensure that TLS 1.2 is being used
If ([Net.SecurityProtocolType]::Tls12 -bor $False) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} Else {}
#endregion

#region Global Variables
# Log Section
$logLocation = 'C:\Temp\'
$logFile = 'Certificate-log.txt'
$logFileLocation = "$($logLocation)$($logFile)"
# Certification Information
$CertificateName = "MyCertificate"
$KeyDescription = "Used to access Microsoft Graph API"
#Certificate validation time
$Dates = 2
# Export Section
$ExportPath = 'C:\Temp\'
$ExportFile = 'MyCertificate.cer'
$ExportFilePath = "$($ExportPath)$($ExportFile)"
#endregion

#region Functions

#Save log of actions taken
function Write-Log {
    param (
        $Message,
        $ForegroundColor = 'White'
    )
    function TimeStamp { return '[{0:yyyy/MM/dd} {0:HH:mm:ss}]' -f (Get-Date) }

    "$(TimeStamp) $Message" | Tee-Object -FilePath $logFileLocation -Append | Write-Verbose
    Write-Host $Message -ForegroundColor $ForegroundColor
}
#endregion

#region Execution
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Renerating the Certificate"
    Write-Log "`t Using PowerShell on your developer computer, run the the following to create your client certificate."
    Write-Log "`t It will be stored in your users certificate store."
    $Cert = New-SelfSignedCertificate -CertStoreLocation cert:\currentuser\my -Subject $CertificateName -KeyDescription $KeyDescription -NotAfter (Get-Date).AddYears($Dates)
    $Cert.Thumbprint | clip
    Write-Log "`t Export certificate"
    Export-Certificate -Type CERT -Cert $Cert -FilePath $ExportFilePath
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
Write-Output "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion