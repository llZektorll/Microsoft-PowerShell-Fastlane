<# 
.SYNOPSIS
    Configuration Script
.DESCRIPTION 
    This script contains all of what is considered a standard configuration on the repository.
    From the log file location to the functions used to connect and fixed variables used on the connections.
    Because it will have fixed variables, it will assume all connections are made with a Azure Application.
    For any connection the Graph Authentication is required
    However since each script will have specific permission  requirements, the permissions needed will be displayed in each one.
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2023-05-02 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    Information about PowerShell Modules to be required.
        NA
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>

#region Variables
$Global:ErrorActionPreference = 'Stop'
$GlobalLocation = (Get-Item $PSCommandPath).DirectoryName
$RootLocation = Split-Path $GlobalLocation
#Log Variables
$LogFile = "MPFL_Log-$(Get-Date -Format 'yyyyMM').txt"
$LogFileLocation = "$($RootLocation)\Logs\$($logFile)"
#Connection Configuration
$Tenant = 'domain.onmicrosoft.com'
$TenantId = '12345678-1234-1234-1234-123456789abc'
$SPOAdminUrl = 'https://domain-admin.sharepoint.com'
$ApplicationId = '12345678-1234-1234-1234-123456789abc'
$CertificateThumbPrint = '0000000000000000000000000000'
#endregion
#region Functions
#region Ensure TLS 1.2
Function EnforceTLS12 {
    Try {
        If ([Net.SecurityProtocolType]::Tls12 -bor $False) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Write-Log "`t Forced TLS 1.2 since its not server default"
        } Else {
            Write-Log "`t TLS 1.2 already configured as server default"
        }
    } Catch {
        Write-Log "`t Unable to check or ensure TLS 1.2 status"
        Write-Log "`t Error: $($_.Exception.Message)"
    }
}
#endregion
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

    "$(TimeStamp) $Message" | Tee-Object -FilePath $logFileLocation -Append | Write-Verbose
    Write-Host $Message -ForegroundColor $ForegroundColor
}
#endregion
#region Connect Exchange Online
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
                Connect-ExchangeOnline -TenantId $TenantId -ApplicationId $ApplicationId -CertificateThumbprint $CertificateThumbPrint
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
                Connect-ExchangeOnline -TenantId $TenantId -ApplicationId $ApplicationId -CertificateThumbprint $CertificateThumbPrint
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
#endregion
#region Connect SharePoint Online
Function Connect-SPO {
    $GetModuleSPO = Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell
    If ($GetModuleSPO -ne 0) {
        Try {
            $GetmoduleSPOUpdate = Read-Host 'Do you want to check if the module have updates? [Y] Yes [N] No'
            If ($GetmoduleSPOUpdate -match '[yY]') {
                Write-Log "`t Checking and installing updates, please wait..."
                Install-Module -Name Microsoft.Online.SharePoint.PowerShell -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to SharePoint Online"
                Connect-SPOService -Url $SPOAdminUrl -TenantId $TenantId -ApplicationId $ApplicationId -CertificateThumbprint $CertificateThumbPrint
            } Else {
                Write-Log "`t Connecting to SharePoint Online without check for module updates"
                Connect-SPOService -Url $SPOAdminUrl -TenantId $TenantId -ApplicationId $ApplicationId -CertificateThumbprint $CertificateThumbPrint
            }
        } Catch {
            Write-Log "`t Error Connecting to SPO: $($_.Exception.Message)"
        }
    } Else {
        Try {
            Write-Log "`t SharePoint Online Module missing."
            $GetModuleSPOInstall = Read-Host 'Do you want to install SharePoint Online Module? [Y]Yes [N]No'
            If ($GetModuleSPOInstall -match '[yY]') {
                Write-Log 'Installing SharePoint Online Module, please wait ...'
                Install-Module -Name Microsoft.Online.SharePoint.PowerShell -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to SharePoint Online"
                Connect-SPOService -Url $SPOAdminUrl -TenantId $TenantId -ApplicationId $ApplicationId -CertificateThumbprint $CertificateThumbPrint
            } Else {
                Write-Log "`t Unable to run the script without SharePoint Online Module."
                Write-Log "`t Terminating the script. Press Enter to exit"
                Read-Host
                Exit
            }
        } Catch {
            Write-Log "`t Error Installing and Connecting to SPO: $($_.Exception.Message)"
        }
    }
}
#endregion
#region Connect PNP PowerShell
Function Connect-PNPPS {
    $GetModulePnpPowerShell = Get-Module -ListAvailable -Name PnP.PowerShell
    If ($GetModulePnpPowerShell -ne 0) {
        Try {
            $GetmodulePnpPowerShellUpdate = Read-Host 'Do you want to check if the module have updates? [Y] Yes [N] No'
            If ($GetmodulePnpPowerShellUpdate -match '[yY]') {
                Write-Log "`t Checking and installing updates, please wait..."
                Install-Module -Name PnP.PowerShell -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to PnP PowerShell"
                Connect-PnpPowerShellService -Url $SPOAdminUrl -TenantId $TenantId -ApplicationId $ApplicationId -CertificateThumbprint $CertificateThumbPrint
            } Else {
                Write-Log "`t Connecting to PnP PowerShell without check for module updates"
                Connect-PnpPowerShellService -Url $SPOAdminUrl -TenantId $TenantId -ApplicationId $ApplicationId -CertificateThumbprint $CertificateThumbPrint
            }
        } Catch {
            Write-Log "`t Error Connecting to PnpPowerShell: $($_.Exception.Message)"
        }
    } Else {
        Try {
            Write-Log "`t PnP PowerShell Module missing."
            $GetModulePnpPowerShellInstall = Read-Host 'Do you want to install PnP PowerShell Module? [Y]Yes [N]No'
            If ($GetModulePnpPowerShellInstall -match '[yY]') {
                Write-Log 'Installing PnP PowerShell Module, please wait ...'
                Install-Module -Name PnP.PowerShell -AllowClobber -Confirm:$False -Force
                Write-Log "`t Connecting to PnP PowerShell"
                Connect-PnpPowerShellService -Url $SPOAdminUrl -TenantId $TenantId -ApplicationId $ApplicationId -CertificateThumbprint $CertificateThumbPrint
            } Else {
                Write-Log "`t Unable to run the script without PnP PowerShell Module."
                Write-Log "`t Terminating the script. Press Enter to exit"
                Read-Host
                Exit
            }
        } Catch {
            Write-Log "`t Error Installing and Connecting to PnPPowerShell: $($_.Exception.Message)"
        }
    }
}
#endregion
#endregion

#Executions

CheckFilePath
EnforceTLS12