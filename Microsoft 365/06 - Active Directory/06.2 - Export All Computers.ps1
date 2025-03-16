<# 
.DESCRIPTION 
    Export All Computers from a specific Organization Unit
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-10
#>
$Global:ErrorActionPreference = 'Stop'
#Organization Unit
$Organization_Unit = 'DC=MPFL,DC=com'
#Computer Information
$Properties = @( # -> Information that will be exported
    'Name',
    'CanonicalName',
    'OperatingSystem',
    'OperatingSystemVersion',
    'LastLogonDate',
    'LogonCount',
    'BadLogonCount',
    'IPv4Address',
    'Enabled',
    'whenCreated'
)
#Log Function
Function Write-Log{
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Message,
        [Parameter(Mandatory=$true)]
        [String]$Type
    )
    $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Log = "$Date - $Type - $Message"
    $Log | Out-File -FilePath "C:\Temp\Log\$(Get-Date -Format "yyyy-MM-dd").log" -Append -NoClobber -Encoding UTF8
}
# Export Location
Function CheckFilePath {
        If (Test-Path -Path "C:\Temp\Log") {}Else {
            New-Item "C:\Temp\Log" -ItemType Directory
        }
        If (Test-Path -Path "C:\Temp\Export") {}Else {
            New-Item "C:\Temp\Export" -ItemType Directory
        }
}
CheckFilePath

Try {
    Write-Log -Message "Gathering all Computers from $($Organization_Unit)" -Type "Information"
    $Equipments = Get-ADComputer -Filter * -SearchBase $Organization_Unit -Properties $Properties | Select-Object $Properties
    Write-Log -Message "Gathered $($Equipments.Count) Computers" -Type "Success"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-Log -Message "Unable to gather Computers" -Type "Error"
    Break
}
Try {
    Write-Log -Message "Exporting all Computers in $($Organization_Unit)" -Type "Information"
    Foreach ($Computer in $Equipments) {
        $Export_Computer = [PSCustomObject][Ordered]@{
            'Name'            = $Computer.Name
            'CanonicalName'   = $Computer.CanonicalName
            'OS'              = $Computer.OperatingSystem
            'OS Version'      = $Computer.OperatingSystemVersion
            'Last Logon'      = $Computer.lastLogonDate
            'Logon Count'     = $Computer.logonCount
            'Bad Logon Count' = $Computer.BadLogonCount
            'IP Address'      = $Computer.IPv4Address
            'Enabled'         = if ($Computer.Enabled) { 'enabled' } else { 'disabled' }
            'Date created'    = $Computer.whenCreated
        }
        $Export_Computer | Export-Csv -Path "C:\Temp\Export\Export_Computers.csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
    Write-Log -Message "Exported all information" -Type "Success"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-Log -Message "Unable to export information" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

