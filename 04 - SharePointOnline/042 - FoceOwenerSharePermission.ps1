<# 
.DESCRIPTION 
    Set site share permissions for only site owners
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2024-03-05 (YYYY-MM-DD)
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#region Variables
$Global:ErrorActionPreference = 'Stop'
$RootLocation = 'C:\Temp'
$LogFile = "$($RootLocation)\Logs\Log$(Get-Date -Format 'yyyyMM').txt"
$ExportFile = "$($RootLocation)\Exports\Export_SiteList.csv"
#Connection
$Tenant = 'contos.onmicrosoft.com'
$Application_ID = 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1'
$Certificate_Thumb_Print = 'H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1'
$SPO_Site = 'https://contoso-admin.sharepoint.com/'
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
Write-Log "`t ==========================================================="
Write-Log "`t ==                                                       =="
Write-Log "`t ==   042 - Force Site Share Permissions Only for Owner   =="
Write-Log "`t ==                                                       =="
Write-Log "`t ==========================================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Enforce TLS 1.2"
    ForceTLS
    
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 2 - Connection to PNP PowerShell"
    Connect-PnPOnline -Url $SPO_Site -Tenant $Tenant -ClientId $Application_ID -Thumbprint $Certificate_Thumb_Print -WarningAction SilentlyContinue -ErrorAction Stop
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 3 - Export all sites"
    $Full_Site_List = Get-PnPTenantSite
    $New_Site_List = @()
    Foreach ($Site in $Full_Site_List) {
        If (($Site.LockState -ne 'NoAccess') -or ($Site.Template -ne 'RedirectSite#0')) {
            $New_Site_List += $Site
        }
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 4 - Get list of already executed sites"
    If (Test-Path $ExportFile -PathType Leaf) {
        $History_Site_List = Import-Csv -Path $ExportFile -Delimiter ';' -Encoding UTF8
    } Else {
        $History_Site_List = 0
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 5 - Match for only new site to aply the changes"
    Foreach ($Site_Url in $New_Site_List) {
        If ($History_Site_List -eq 0) {
            Connect-PnPOnline -Url $Site_Url -Tenant $Tenant -ClientId $Application_ID -Thumbprint $Certificate_Thumb_Print -WarningAction SilentlyContinue -ErrorAction Stop
            Set-PnPSite -DisableSharingForNonOwners
            Write-Log "`t Disabled for: $($Site.Url)"
            $ObjectExport = [pscustomobject]@{
                'URL' = $Site.Url
            }
            $ObjectExport | Export-Csv -Path $ExportLocation -Delimiter ';' -Encoding UTF8 -NoClobber -NoTypeInformation -Append
        } Else {
            If ($History_Site_List -notcontains $Site_Url.Url) {
                Connect-PnPOnline -Url $Site_Url -Tenant $Tenant -ClientId $Application_ID -Thumbprint $Certificate_Thumb_Print -WarningAction SilentlyContinue -ErrorAction Stop
                Set-PnPSite -DisableSharingForNonOwners
                Write-Log "`t Disabled for: $($Site.Url)"
                $ObjectExport = [pscustomobject]@{
                    'URL' = $Site.Url
                }
                $ObjectExport | Export-Csv -Path $ExportLocation -Delimiter ';' -Encoding UTF8 -NoClobber -NoTypeInformation -Append
            }
        }
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