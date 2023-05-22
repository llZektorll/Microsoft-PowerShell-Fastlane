<# 
.SYNOPSIS
    Clear Office 365 Apps cache
.DESCRIPTION 
    Removes all cache on the equipment for any Office 365 resource 
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos (https://github.com/llZektorll)
    Creation Date: 2023-05-09 (YYYY-MM-DD)
    Change: Initial script development
.COMPONENT 
    Connection modules include
        NA
.LINK 
    Script repository: https://github.com/llZektorll/Microsoft-PowerShell-Fastlane
#>
#Adding the configuration file to be ran 
. '.\Microsoft-PowerShell-Fastlane\1-ToolKits\TK0-Config.ps1'
#region Variables
$RootFolder = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$Fodler, $User = $RootFolder.split('\')

$FoldersTeams = @(
    'application cache',
    'blob_storage',
    'databases',
    'GPUcache',
    'IndexedDB',
    'Local Storage',
    'tmp'
)
#endregion 

#region Execution
Write-Log "`t ==========================================="
Write-Log "`t ==                                       =="
Write-Log "`t ==     Office 365 Apps Cache Celaner     =="
Write-Log "`t ==                                       =="
Write-Log "`t ==========================================="
Write-Log "`t Start Script Run"
Try {
    Write-Log "`t Step 1 - Closing all Apps"
    Try{
        If(Get-Process -ProcessName Teams -ErrorAction SilentlyContinue){
            Get-Process -ProcessName Teams | Stop-Process -Force
        }
        If(Get-Process -ProcessName Outlook -ErrorAction SilentlyContinue){
            Get-Process -ProcessName Outlook | Stop-Process -Force
        }
        If(Get-Process -ProcessName OneNote -ErrorAction SilentlyContinue){
            Get-Process -ProcessName OneNote | Stop-Process -Force
        }
    }Catch{
        Write-Log "`t Error: $($_.Exception.Message)"
    }
    Write-Log "`t Step 2 - Removing all Cache"
    Try{
    Foreach($Item in $FoldersTeams){
        Get-ChildItem -Path "C:\Users\$($User)\Microsoft\Teams\$($Item)" | Remove-Item -Recurse -Confirm:$False -Force
    }
    Get-ChildItem -Path "Local\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy\AC\TokenBroker\Accounts" | Remove-Item -Recurse -Confirm:$False -Force
    } Catch {
        Write-Log "`t Error: $($_.Exception.Message)"
    }

} Catch {
    Write-Log "`t Error: $($_.Exception.Message)"
}

Write-Log "`t More scripts like this in https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
#endregion