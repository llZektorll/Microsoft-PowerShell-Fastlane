<# 
.DESCRIPTION 
    Export All the users inside a specific Organization Unit
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-10
#>
$Global:ErrorActionPreference = 'Stop'
#Organization Unit
$Organization_Unit = 'DC=contoso,DC=com'
#Computer Information
#Groups information to Export
$Properties = @(
    'Name',
    'UserPrincipalName',
    'distinguishedName'
    'mail'
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

Try{
    Write-log -Message "Collecting all Users" -Type "Information"
    $Users = Get-ADUser -SearchBase $Organization_Unit -Properties $Properties | Select-Object $Properties
    Write-log -Message "Collecting $($Users.Count) Users" -Type "Sucess"
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to collect Users" -Type "Error"
    Break
}

Try{
    Write-log -Message "Exporting User Information" -Type "Information"
    Foreach ($User in $Users) {
        $Export_Users = [PSCustomObject][Ordered]@{
            'Name'                = $User.Name
            'UserPrincipalName'   = $User.UserPrincipalName
            'distinguishedName'   = $User.distinguishedName
            'mail'                = $User.mail
        }
        $Export_Users | Export-Csv -Path "C:\Temp\Export\Export_Users.csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
    Write-log -Message "Collecting all Users" -Type "Sucess"
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to export users" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

