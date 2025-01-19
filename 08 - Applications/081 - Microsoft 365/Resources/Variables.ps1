#region Variables 
#Global Variables
[String]$Root_Path = $MyInvocation.MyCommand.Path
#Version Control
$Sync = [hashtable]::Synchronized(@{})
$Sync.PSScriptRoot = $Root_Path
$Sync.Version = '0.0.1'
$Sync.Config = @{}
$sync.ProcessRunning = $false
#Base Directory
$Log_Dir = "C:\Temp\MPFL-M365\Logs)"
$Log_Export = "C:\Temp\MPFL-M365\Export)"
#endregion