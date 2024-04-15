<# 
.DESCRIPTION 
    Export all users from OU
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2024-04-15 (YYYY-MM-DD)
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#region Variables
$Global:ErrorActionPreference = 'Stop'
$RootLocation = 'C:\Temp'
$LogFile = "$($RootLocation)\Logs\Log$(Get-Date -Format 'yyyyMM').txt"
$ExportFile = "$($RootLocation)\Exports\Export_$(Get-Date -Format 'yyyyMM').csv"
# Users to Export
$Properties = @(
    'Name',
    'UserPrincipalName',
    'distinguishedName'
    'mail',
    'extensionAttribute2',
    'extensionAttribute3',
    'extensionAttribute5'
)
# OU Location
$OU = 'DC=contoso,DC=com'
#endregion 

#region Functions
#region Variable Cleaner
Function VarCleaner {
    $RootLocation = $null
    $LogFile = $null
    $ExportFile = $null
    $Message = $null
    $ForegroundColor = $null
    $Properties = $null
    $OU = $null
    $GetUsers = $null
    $User = $null
    $ObjectDetail = $null
}
#endregion
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
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==     024 - Expor all User from OU      =="
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
    Write-Log "`t Step 2 - Collecting Users"
    $GetUsers = Get-ADUser -SearchBase $OU -Properties $Properties | Select-Object $Properties
    Write-Log "`t Step 2.2 - Exporting Informaiton"
    Foreach ($User in $GetUsers) {
        $ObjectDetail = [PSCustomObject][Ordered]@{
            'Name'                = $User.Name
            'UserPrincipalName'   = $User.UserPrincipalName
            'distinguishedName'   = $User.distinguishedName
            'mail'                = $User.mail
            'extensionAttribute2' = $User.extensionAttribute2
            'extensionAttribute3' = $User.extensionAttribute3
            'extensionAttribute5' = $User.extensionAttribute5
        }
        $ObjectDetail | Export-Csv $ExportFile -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
VarCleaner
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion