<# 
.SYNOPSIS
    Export a list of all groups
.DESCRIPTION 
    Export a list with all Groups to a CSV
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2024-02-07 (YYYY-MM-DD)
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#region Variables
$Global:ErrorActionPreference = 'Stop'
$RootLocation = 'C:\Temp'
$LogFile = "$($RootLocation)\Logs\Log$(Get-Date -Format 'yyyyMM').txt"
$ExportFile = "$($RootLocation)\Exports\Export.csv"
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
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==          Export All Groups            =="
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
    Write-Log "`t Step 2 - Connecting to Exchange Online"
    Connect-ExchangeOnline
    Connect-AzureAD
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 3 - Colecting All Groups"
    $Groups = Get-UnifiedGroup -ResultSize Unlimited | Select-Object DisplayName,SharePointSiteURL,Alias,PrimarySmtpAddress,IsMembershipDynamic,ResourceProvisioningOptions,HiddenFromAddressListsEnabled,GroupMemberCount,ExpirationTime,WhenCreated,WhenChanged,ExternalDirectoryObjectId
    Foreach ($Group in $Groups) {
        $GroupOwner = Get-AzureADGroupOwner -ObjectId "$($Group.ExternalDirectoryObjectId)" | Select-Object MailNickName
        $Export = [PSCustomObject][Ordered]@{
            DisplayName                   = $Group.DisplayName
            SharePointSiteURL             = $Group.SharePointSiteURL
            Alias                         = $Group.Alias
            PrimarySmtpAddress            = $Group.PrimarySmtpAddress
            IsMembershipDynamic           = $Group.IsMembershipDynamic
            ResourceProvisioningOptions   = $Group.ResourceProvisioningOptions
            HiddenFromAddressListsEnabled = $Group.HiddenFromAddressListsEnabled
            GroupMemberCount              = $Group.GroupMemberCount
            ExpirationTime                = $Group.ExpirationTime
            WhenCreated                   = $Group.WhenCreated
            WhenChanged                   = $Group.WhenChanged
            Owner                         = $GroupOwner.MailNickName -join ('|')
        }
        $Export | Export-Csv $ExportFile -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion