#requires -runasadministrator
<# 
.DESCRIPTION 
    Disable services in Windows 10
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-18
#>
$Global:ErrorActionPreference = 'Stop'
$Services = @(
    'DcpSvc'                                   # Data Collection and Publishing Service
    'diagnosticshub.standardcollector.service' # Microsoft (R) Diagnostics Hub Standard Collector Service
    'DiagTrack'                                # Diagnostics Tracking Service
    'SensrSvc'                                 # Monitors Various Sensors
    'dmwappushservice'                         # WAP Push Message Routing Service
    'lfsvc'                                    # Geolocation Service
    'MapsBroker'                               # Downloaded Maps Manager
    'NetTcpPortSharing'                        # Net.Tcp Port Sharing Service
    'RemoteAccess'                             # Routing and Remote Access
    'RemoteRegistry'                           # Remote Registry
    'SharedAccess'                             # Internet Connection Sharing (ICS)
    'TrkWks'                                   # Distributed Link Tracking Client
    'WbioSrvc'                                 # Windows Biometric Service
    'WMPNetworkSvc'                            # Windows Media Player Network Sharing Service
    'WSearch'                                  # Windows Search
    # XBox Based Services
    'XblAuthManager'                           # Xbox Live Auth Manager
    'XblGameSave'                              # Xbox Live Game Save Service
    'XboxNetApiSvc'                            # Xbox Live Networking Service
    # Windows HomeGroup Services
    'HomeGroupListener'                        # HomeGroup Listener
    'HomeGroupProvider'                        # HomeGroup Provider
    # Other Optional
    'bthserv'                                 # Bluetooth Support Service
    'wscsvc'                                  # Security Center Service
    'WlanSvc'                                 # WLAN AutoConfig
    'OneSyncSvc'                               # Sync Host Service
    'AeLookupSvc'                              # Application Experience Service
    'PcaSvc'                                   # Program Compatibility Assistant
    'WinHttpAutoProxySvc'                     # WinHTTP Web Proxy Auto-Discovery
    'UPNPHOST'                                 # Universal Plug & Play Host
    'ERSVC'                                    # Error Reporting Service
    'WERSVC'                                   # Windows Error Reporting Service
    'SSDPSRV'                                  # SSDP Discovery Service
    'CDPSvc'                                   # Connected Devices Platform Service
    'DsSvc'                                    # Data Sharing Service
    'DcpSvc'                                   # Data Collection and Publishing Service
    'lfsvc'                                    # Geolocation service
)
#Log Function
Function Write-Log {
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Message,
        [Parameter(Mandatory = $true)]
        [String]$Type
    )
    $Date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $Log = "$Date - $Type - $Message"
    $Log | Out-File -FilePath "C:\Temp\Log\$(Get-Date -Format 'yyyy-MM-dd').log" -Append -NoClobber -Encoding UTF8
}
# Export Location
Function CheckFilePath {
    If (Test-Path -Path 'C:\Temp\Log') {}Else {
        New-Item 'C:\Temp\Log' -ItemType Directory
    }
}
CheckFilePath

Try {
    Write-log -Message 'Disable Services' -Type 'Information'
    foreach ($Service in $Services) {
        if ( Get-Service "$($Service)*" -Include $Service ) {
            Get-Service -Name $Service | Stop-Service -Force
            Get-Service -Name $Service | Set-Service -StartupType Disabled
            Write-log -Message "Disabled $($Service)" -Type 'Execution'
        }
    }
    Write-log -Message 'All services Disabled' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to disable all services' -Type 'Error'
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne 'n') {
    Start-Process 'https://github.com/llZektorll/Microsoft-PowerShell-Fastlane'
} else {
    break
}
