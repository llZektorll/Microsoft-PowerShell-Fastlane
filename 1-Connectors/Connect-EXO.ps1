Function Connect-EXO {
    $GetModuleEXO = Get-Module -ListAvailable -Name ExchangeOnlineManagement
    If ($GetModuleEXO -ne 0) {
        Try {
            $GetmoduleExoUpdate = Read-Host 'Do you want to check if the module have updates? [Y] Yes [N] No'
            If ($GetmoduleExoUpdate -match '[yY]') {
                Write-Log "`t Checking and installing updates, please wait..."
                Install-Module -Name ExchangeOnlineManagement -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to Exchange Online"
                Connect-ExchangeOnline
            } Else {
                Write-Log "`t Connecting to Exchange Online without check for module updates"
                Connect-ExchangeOnline
            }
        } Catch {
            Write-Log "`t Error Connecting to EXO: $($_.Exception.Message)"
        }
    } Else {
        Try {
            Write-Log "`t Exchange Online module missing."
            $GetModuleEXOInstall = Read-Host 'Do you want to install Exchange Online Module? [Y]Yes [N]No'
            If ($GetModuleEXOInstall -match '[yY]') {
                Write-Log 'Installing Exchange Online Module, please wait ...'
                Install-Module -Name ExchangeOnlineManagement -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to Exchange Online"
                Connect-ExchangeOnline
            } Else {
                Write-Log "`t Unable to run the script without Exchange Online Module."
                Write-Log "`t Terminating the script. Press Enter to exit"
                Read-Host
                Exit
            }
        } Catch {
            Write-Log "`t Error Installing and Connecting to EXO: $($_.Exception.Message)"
        }
    }
}