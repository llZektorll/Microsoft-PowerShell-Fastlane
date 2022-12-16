Function Connect-AAD {
    $GetModuleAAD = Get-Module -ListAvailable -Name AzureAD
    If ($GetModuleAAD -ne 0) {
        Try {
            $GetmoduleAADUpdate = Read-Host 'Do you want to check if the module have updates? [Y] Yes [N] No'
            If ($GetmoduleAADUpdate -match '[yY]') {
                Write-Log "`t Checking and installing updates, please wait..."
                Install-Module -Name AzureAD -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to Azure Active Directory"
                Connect-AzureAD
            } Else {
                Write-Log "`t Connecting to Azure Active Directory without check for module updates"
                Connect-AzureAD
            }
        } Catch {
            Write-Log "`t Error Connecting to Azure Active Directory: $($_.Exception.Message)"
        }
    } Else {
        Try {
            Write-Log "`t Azure Active Directory module missing."
            $GetModuleAADInstall = Read-Host 'Do you want to install Azure Active Directory Module? [Y]Yes [N]No'
            If ($GetModuleAADInstall -match '[yY]') {
                Write-Log 'Installing Azure Active Directory Module, please wait ...'
                Install-Module -Name AzureAD -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to Azure Active Directory"
                Connect-AzureAD
            } Else {
                Write-Log "`t Unable to run the script without Azure Active Directory Module."
                Write-Log "`t Terminating the script. Press Enter to exit"
                Read-Host
                Exit
            }
        } Catch {
            Write-Log "`t Error Installing and Connecting to Azure Active Directory: $($_.Exception.Message)"
        }
    }
}