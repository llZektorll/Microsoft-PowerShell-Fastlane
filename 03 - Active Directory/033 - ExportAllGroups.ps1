<# 
.DESCRIPTION 
    Export all groups from OU
.NOTES 
    Vertsion:   2.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2024-08-29 (YYYY-MM-DD)
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#region Global Variables
$Global:ErrorActionPreference = 'Stop'
$RootLocation = 'C:\Temp\'
$LogFile = "$($RootLocation)Logs\Log$(Get-Date -Format 'yyyyMM').txt"
$ExportFile = "$($RootLocation)Exports\Export_$(Get-Date -Format 'yyyyMM').csv"
#Groups information to Export
$Properties = @(
    'Name',
    'CanonicalName',
    'GroupCategory',
    'GroupScope',
    'ManagedBy',
    'MemberOf',
    'created',
    'whenChanged',
    'mail',
    'info',
    'description'
)
# OU Lcoation
$OU = 'DC=contoso,DC=com'
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
Write-Log "`t ==    033 - Export all Grous from OU     =="
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
    Write-Log "`t Step 2 - Collecting information"
    $Groups = Get-ADGroup -SearchBase $OU -Filter * -Properties $Properties | Select-Object $Properties
    Write-Log "`t Step 1.2 - Exporting Information"
    Foreach ($Group in $Groups) {
        If ($Null -ne $_.ManagedBy) {
            $Manager = Get-ADUser -Identity $_.ManagedBy | Select-Object -ExpandProperty name
        } Else {
            $Manager = 'Not Set'
        }
        $ObjectDetail = [PSCustomObject][Ordered]@{
            'Name'          = $Group.Name
            'CanonicalName' = $Group.CanonicalName
            'GroupCategory' = $Group.GroupCategory
            'GroupScope'    = $Group.GroupScope
            'Mail'          = $Group.Mail
            'Description'   = $Group.Description
            'Info'          = $Group.info
            'ManagedBy'     = $Manager
            'MemberOf'      = ($memberOf | Out-String).Trim()
            'Date created'  = $Group.created
            'Date changed'  = $Group.whenChanged
        }
        $ObjectDetail | Export-Csv $ExportFile -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion