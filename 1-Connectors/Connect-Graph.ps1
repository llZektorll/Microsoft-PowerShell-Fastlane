$TenantId = "" # Place your tenant ID
$ClientId = "" # Place the Application client ID
$Thumbprint = "" # Place the certificate Thumbprint
Function Connect-MSGra {
    $GetMoguleGraph = Get-Module -ListAvailable -Name Microsoft.Graph
    If ($GetMoguleGraph -ne 0) {
        Try {
            $GetMoguleGraphUpdate = Read-Host 'Do you want to check if the module have updates? [Y] Yes [N] No'
            If ($GetMoguleGraphUpdate -match '[yY]') {
                Write-Log "`t Checking and installing updates, please wait..."
                Install-Module -Name Microsoft.Graph -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to Microsoft Graph"
                Connect-Graph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $Thumbprint
            } Else {
                Write-Log "`t Connecting to Microsoft Graph without check for module updates"
                Connect-Graph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $Thumbprint
            }
        } Catch {
            Write-Log "`t Error Connecting to Microsoft Graph: $($_.Exception.Message)"
        }
    } Else {
        Try {
            Write-Log "`t Microsoft Graph module missing."
            $GetMoguleGraphInstall = Read-Host 'Do you want to install Microsoft Graph Module? [Y]Yes [N]No'
            If ($GetMoguleGraphInstall -match '[yY]') {
                Write-Log 'Installing Microsoft Graph Module, please wait ...'
                Install-Module -Name Microsoft.Graph -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to Microsoft Graph"
                Connect-Graph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $Thumbprint
            } Else {
                Write-Log "`t Unable to run the script without Microsoft Graph Module."
                Write-Log "`t Terminating the script. Press Enter to exit"
                Read-Host
                Exit
            }
        } Catch {
            Write-Log "`t Error Installing and Connecting to Microsoft Graph: $($_.Exception.Message)"
        }
    }
}