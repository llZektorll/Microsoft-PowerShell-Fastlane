<# 
.DESCRIPTION 
    Force version control on all document libraries. 
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2024-04-23 (YYYY-MM-DD)
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#region Variables
$Global:ErrorActionPreference = 'Stop'
$RootLocation = 'C:\Temp'
$LogFile = "$($RootLocation)\Logs\Log$(Get-Date -Format 'yyyyMM').txt"
#region site
$Admin_Site = 'https://contoso-admin.sharepoint.com'
#endregion

#region Functions
#region Ensure TLS 1.2
Function ForceTLS {
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
Write-Log "`t ==      042 - Force Version Limit        =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Enforce TLS 1.2"
    ForceTLS
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 2 - Connection to PNP PowerShell"
    Connect-PnPOnline -Url $Admin_Site -UseWebLogin
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 3 - Get all sites"
    $All_Sites = Get-PnPTenantSite
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 3 - Set version limit"
    Foreach ($Site in $All_Sites) {
        $Site_Connection = Connect-PnPOnline $Site.Url -Interactive -ReturnConnection
        $Document_Libraries = Get-PnPList -Connection $Site_Connection | Where-Object { $_.BaseTemplate -eq 101 -and $_.Hidden -eq $false } 
        Write-Host "Processing site $($Site.Url)"
        Foreach ($Document_Librarie in $Document_Libraries) {
            If ($Document_Librarie.Title -eq 'Style Library') {
                Continue
            }
            Set-PnPList -Identity $Document_Librarie -MajorVersions 50 -Connection $Site_Connection
        }
        Disconnect-PnPOnline -Connection $Site_Connection
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}













Try {
    Write-Log "`t Step 2 - "

} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion