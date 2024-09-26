#Requires -Version 7.0
<# 
.DESCRIPTION 
    List all workspaces and owner/admins for each one
.NOTES 
    Vertsion:   2.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2024-09-02 (YYYY-MM-DD)
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#region Global Variables
$Global:ErrorActionPreference = 'Stop'
$RootLocation = 'C:\Temp\'
$LogFile = "$($RootLocation)Logs\Log$(Get-Date -Format 'yyyyMM').txt"
$ExportFile = "$($RootLocation)Exports\Export_$(Get-Date -Format 'yyyyMM').csv"
#Connection
$TenantId = 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1'
$Application_ID = 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1'
$Certificate_Thumb_Print = 'H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1'
#endregion
#region Main Functions
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
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
}
#endregion
#endregion
#region Execution
Try {
    CheckFilePath
} Catch {
    Write-Host "`t Unable to check folders for logs"
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==      051 - Worspace Full Report       =="
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
    Write-Log "`t Step 2 - Connecting to PowerBI"
    Connect-PowerBIServiceAccount -ClientId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -TenantId $TenantId
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 3 - Connecting to Microsoft Graph"
    Connect-MgGraph -ClientId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -TenantId $TenantId
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 4 - Gathering all WorkSpaces"
    $WorkSpaces = Get-PowerBIWorkspace -Scope Organization -All
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 5 - Sorting Information"
    Foreach ($WorkSpace in $WorkSpaces) {
        $WorkSpacePermissions = $WorkSpace.Users
        if ($WorkSpacePermissions -eq $null -or $WorkSpacePermissions.Count -eq 0 -or ($WorkSpacePermissions | Where-Object { $_.AccessRight -contains 'None' })) {
            $Admin_Level = 'No Users'
            $Admin_Acc = 'No Users'
        } else {        
            $adminFound = $false
            foreach ($Row in $WorkSpacePermissions) {
                if ($Row.AccessRight -match 'Admin') {
                    $Admin_Level = $Row.AccessRight
                    $Admin_Acc = $Row.UserPrincipalName
                    $adminFound = $true
                    break
                } else {
                    $Admin_Level = $Row.AccessRight
                    $Admin_Acc = $Row.UserPrincipalName
                }
            }
            if (-not $adminFound) {
                $Admin_Level = 'No Admin'
                $Admin_Acc = 'No Admin'
            }
        }
        $Expoter = [PSCustomObject]@{
            'WorkSpace ID'                   = $WorkSpace.Id
            'WorkSpace Name'                 = $WorkSpace.Name
            'WorkSpace Type'                 = $WorkSpace.Type
            'Capacity ID'                    = $WorkSpace.CapacityId
            'WorkSpace WorkSpacePermissions' = $Admin_Level
            'WorkSpace Permission User'      = $Admin_Acc

        }
        $Expoter | Export-Csv -Path $ExportFile -Delimiter ',' -NoTypeInformation -NoClobber -Encoding UTF8 -Append
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion