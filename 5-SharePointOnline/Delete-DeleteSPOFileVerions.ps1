<# 
.SYNOPSIS
    Delete all file verions from a site
.DESCRIPTION 
    Deletes all the versions of any file in the specified site
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2023-05-11 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    Connection modules include 
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#Adding the configuration file to be ran 
. '.\Microsoft-PowerShell-Fastlane\1-ToolKits\TK0-Config.ps1'
#region Variables
#site
$MySiteToClean = 'https://domain-admin.sharepoint.com/site/TestSite'
#endregion 

#region Functions

#endregion

#region Execution
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==       Delete SPO File Versions        =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Connecting to the Site with PNP PowerShell"
    Connect-PNPPS
    Connect-PnPOnline -Url $MySiteToClean -ClientId $clientID -Tenant $Tenant -Thumbprint $certThumbprint
} Catch {
    Write-Log "`t Step 1.1 - Unable to connec to the Site with PNP PowerShell"
    Write-Log "`t Error: $($_.Exception.Message)"
    Exit
}
Try {
    Write-Log "`t Step 2 - Gathering Information "
    $Contx = Get-PnPContext
    $DocumentLibraries = Get-PnPList | Where-Object { $_.BaseType -eq 'DocumentLibrary' -and $_.Hidden -eq $false }
} Catch {
    Write-Log "`t Step 2.1 - Unable to Gather Information "
    Write-Log "`t Error: $($_.Exception.Message)"
    Exit
}
Try {
    Write-Log "`t Step 3 - Cleaning versions"
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
    Write-Log "`t Step 3.1 - All file versions removed"
} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}
Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion