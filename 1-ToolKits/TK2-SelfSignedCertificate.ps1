<# 
.SYNOPSIS
    Self Signed Certificate
.DESCRIPTION 
    Generate and install a Self Signed Certificate
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2024-01-27 (YYYY-MM-DD)
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#region Variables
$Global:ErrorActionPreference = 'Stop'
$RootLocation = 'C:\Temp'
$LogFile = "$($RootLocation)\Logs\Log$(Get-Date -Format 'yyyyMM').txt"
$ExportFile = "$($RootLocation)\Exports"
# Certificate Variables
$CertificateName = 'MyCertificate'
$KeyDescription = 'Certificate for Azure App Registration'
$Dates = 1 # Value in Years
$File = 'MyCertificate.cer'
$ExportFilePath = "$($ExportFile)\$($File)"
#endregion 

#region Functions

#region Check Log File Location
Function CheckFilePath {
    If (Test-Path -Path "$($RootLocation)\Logs\") {}Else {
        New-Item "$($RootLocation)\Logs" -ItemType Directory
    }
    If (Test-Path -Path "$($RootLocation)\Exports\") {}Else {
        New-Item "$($RootLocation)\Exports" -ItemType Directory
    }
}
#endregion
#region Write Log
function Write-Log {
    param (
        $Message,
        $ForegroundColor = 'White'
    )
    function TimeStamp { return '[{0:yyyy/MM/dd} {0:HH:mm:ss}]' -f (Get-Date) }

    "$(TimeStamp) $Message" | Tee-Object -FilePath $LogFile -Append | Write-Verbose
    Write-Host $Message -ForegroundColor $ForegroundColor
}
#endregion
#endregion

#region Execution
Try {
    CheckFilePath
} Catch {
    Write-Host "`t Unable to check folders for logs"
    Write-Host "`t Error: $($_.Exception.Message)"
}
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==          TK2 - Certificate            =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
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