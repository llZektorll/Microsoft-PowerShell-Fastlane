<# 
.DESCRIPTION 
    Deletes all file versions in a site using PNP PowerShell
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
#Site information
$MySiteToClean = 'https://domain-admin.sharepoint.com/site/TestSite'
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
Write-Log "`t ==      041 - Delete File Versions       =="
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
    Write-Log "`t Step 2 - Connecting to SharePoint With PNP PowerShell"
    Connect-PnPOnline -Url $MySiteToClean -Interactive
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 3 - Gathering information"
    $Contx = Get-PnPContext
    $DocumentLibraries = Get-PnPList | Where-Object { $_.BaseType -eq 'DocumentLibrary' -and $_.Hidden -eq $false }
    
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Try {
    Write-Log "`t Step 4 - Cleaning versions"
    $i = 1
    $CountDocLib = $DocumentLibraries.count
    Foreach ($Library in $DocumentLibraries) {
        Write-Progress -Activity 'Cleaning Versions' -Status "Current count: $($i) of $($CountDocLib) Document Libraries" -PercentComplete (($i / $CountDocLib) * 100) 
        Write-Log "`t Processing Document Library:'$Library.Title"
        $ListItems = Get-PnPListItem -List $Library -PageSize 2000 | Where-Object { $_.FileSystemObjectType -eq 'File' }
        Foreach ($Item in $ListItems) {
            #Get File Versions
            $File = $Item.File
            $Versions = $File.Versions
            $Contx.Load($File)
            $Contx.Load($Versions)
            $Contx.ExecuteQuery()
            $VersionsCount = $Versions.Count
            If ($VersionsCount -gt 0) {
                $Versions.DeleteAll()
                Invoke-PnPQuery
            }
        }
        $i++
    }
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Disconnect-PnPOnline
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion