<# 
.SYNOPSIS
    Add files with verstion to spo site
.DESCRIPTION 
    Add files with x versions to a SPO site
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2024-02-11 (YYYY-MM-DD)
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#region Variables
$Global:ErrorActionPreference = 'Stop'
$RootLocation = 'C:\Temp'
$LogFile = "$($RootLocation)\Logs\Log$(Get-Date -Format 'yyyyMM').txt"
#Connection
$SiteURL = 'https://domain.sharepoint.com/teams/TestSite'
$Tenant = 'domain.onmicrosoft.com'
$clientID = '7777777-7777-7777-7777-777777777'
$certThumbprint = '0000000000000000000000000000000000'
#Files
$VersionCount = 100 # Number of versions for each file
$File1 = 'C:\Temp\TheFile1.ps1'
$File2 = 'C:\Temp\TheFile2.docx'
$File3 = 'C:\Temp\TheFile3.xlsx'
$File4 = 'C:\Temp\TheFile4.txt'
$File5 = 'C:\Temp\TheFile5.csv'
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
Write-Log "`t ==           Add files verions           =="
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
    Write-Log "`t Step 2 - Connecting to PNP PowerShell"
    Connect-PnPOnline -Url $SiteURL -ClientId $clientID -Tenant $Tenant -Thumbprint $certThumbprint
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 3 - Adding 100 versions of 5 files"
    $i = 0
    while ($i -ne $VersionCount) {
        Write-Host $i
        Add-PnPFile -Path $File1 -Folder 'Shared Documents/Test_1'
        Add-PnPFile -Path $File2 -Folder 'Shared Documents/Test_1'
        Add-PnPFile -Path $File3 -Folder 'Shared Documents/Test_1'
        Add-PnPFile -Path $File4 -Folder 'Shared Documents/Test_1'
        Add-PnPFile -Path $File5 -Folder 'Shared Documents/Test_1'
        $i++
    
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion