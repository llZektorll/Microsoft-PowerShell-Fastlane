<# 
.DESCRIPTION 
    Export all groups in a Organization Unit
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
    Write-log -Message "Collecting all Groups" -Type "Information"
    $Groups = Get-ADGroup -SearchBase $Organization_Unit -Filter * -Properties $Properties | Select-Object $Properties
    Write-log -Message "Collected $($Groups.count) Groups" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to collect Groups" -Type "Error"
}

Try {
    Write-log -Message "Exporting Groups Information" -Type "Information"
    Foreach ($Group in $Groups) {
        If ($Null -ne $_.ManagedBy) {
            $Manager = Get-ADUser -Identity $_.ManagedBy | Select-Object -ExpandProperty name
        } Else {
            $Manager = 'Not Set'
        }
        $Export_Groups = [PSCustomObject][Ordered]@{
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
        $Export_Groups | Export-Csv -Path "C:\Temp\Export\Export_Groups.csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to export Groups" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

