<# 
.DESCRIPTION 
    Get all PowerBI workspaces and the admins for each workspace
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2024-04-17 (YYYY-MM-DD)
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#region Variables
$Global:ErrorActionPreference = 'Stop'
$RootLocation = 'C:\Temp'
$LogFile = "$($RootLocation)\Logs\Log$(Get-Date -Format 'yyyyMM').txt"
$ExportFile = "$($RootLocation)\Exports\Export_$(Get-Date -Format 'yyyyMM').csv"
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
Write-Log "`t ==================================================="
Write-Log "`t ==                                               =="
Write-Log "`t ==  061 - Export PowerBi Workspace and Owners    =="
Write-Log "`t ==                                               =="
Write-Log "`t ==================================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Enforce TLS 1.2"
    ForceTLS
    
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 2 - Connecting to PowerBI"
    #Connect-PowerBIServiceAccount
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 3 - Gathering all WorkSpaces"
    $WorkSpaces = Get-PowerBIWorkspace -Scope Organization -All
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 4 - Sorting Information"
    Foreach ($WorkSpace in $WorkSpaces) {
        $Permissions = $WorkSpace.Users
        If ($null -eq $Permissions) {
            $Admin_Level = 'No Users'
            $Admin_Acc = 'No Users'
        } Else {        
            Foreach ($Row in $Permissions) {
                If ($Row.AccessRight -match 'Admin') {
                    $Admin_Level = $Row.AccessRight
                    $Admin_Acc = $Row.UserPrincipalName
                } Else {
                    $Admin_Level = $Row.AccessRight
                    $Admin_Acc = $Row.UserPrincipalName
                }
            }
        }
        $Expoter = [PSCustomObject]@{
            'WorkSpace ID'              = $WorkSpace.Id
            'WorkSpace Name'            = $WorkSpace.Name
            'WorkSpace Type'            = $WorkSpace.Type
            'Capacity ID'               = $WorkSpace.CapacityId
            'WorkSpace Permissions'     = $Admin_Level
            'WorkSpace Permission User' = $Admin_Acc

        }
        $Expoter | Export-Csv -Path $ExportFile -Delimiter ',' -NoTypeInformation -NoClobber -Encoding UTF8 -Append
        $Permissions = $null
        $Admin_Level = $null
        $Admin_Acc = $null
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion
