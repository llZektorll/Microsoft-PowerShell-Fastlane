Function Connect-Teams {
    $GetModuleTeams = Get-Module -ListAvailable -Name MicrosoftTeams
    If ($GetModuleTeams -ne 0) {
        Try {
            $GetmoduleTeamsUpdate = Read-Host 'Do you want to check if the module have updates? [Y] Yes [N] No'
            If ($GetmoduleTeamsUpdate -match '[yY]') {
                Write-Log "`t Checking and installing updates, please wait..."
                Install-Module -Name MicrosoftTeams -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to Teams"
                Connect-ExchangeOnline
            } Else {
                Write-Log "`t Connecting to Teams without check for module updates"
                Connect-ExchangeOnline
            }
        } Catch {
            Write-Log "`t Error Connecting to Teams: $($_.Exception.Message)"
        }
    } Else {
        Try {
            Write-Log "`t Teams module missing."
            $GetModuleTeamsInstall = Read-Host 'Do you want to install Teams Module? [Y]Yes [N]No'
            If ($GetModuleTeamsInstall -match '[yY]') {
                Write-Log 'Installing Teams Module, please wait ...'
                Install-Module -Name MicrosoftTeams -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to Teams"
                Connect-MicrosoftTeams
            } Else {
                Write-Log "`t Unable to run the script without Teams Module."
                Write-Log "`t Terminating the script. Press Enter to exit"
                Read-Host
                Exit
            }
        } Catch {
            Write-Log "`t Error Installing and Connecting to Teams: $($_.Exception.Message)"
        }
    }
}