<# 
.DESCRIPTION 
    Export User Roles from Azure AD
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-12
#>
If ([Net.SecurityProtocolType]::Tls12 -bor $False) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "`t Forced TLS 1.2 since its not server default"
}
$Global:ErrorActionPreference = 'Stop'
# Connection Variables
$Tenant_ID = '9023f0ij'
$Application_ID = 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1'
$Certificate_Thumb_Print = 'H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1'
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
    Write-log -Message "Connecting to Graph" -Type "Information"
    Connect-MgGraph -ClientId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -TenantId $Tenant_ID
    Write-log -Message "Connected" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to connect" -Type "Error"
}

Try {
    Write-log -Message "Collecting role assignments" -Type "Information"
    $Roles = Get-MgRoleManagementDirectoryRoleAssignment -All -ExpandProperty Principal
    $Roles_1 = Get-MgRoleManagementDirectoryRoleAssignment -All -ExpandProperty roleDefinition
    ForEach ($Role in $Roles) {
        Add-Member -InputObject $Role -MemberType NoteProperty -Name roleDefinition1 -Value ($Roles_1 | Where-Object { $_.id -eq $Role.id }).roleDefinition
    }
    Write-log -Message "Foud a total of $($Roles.Count) roles" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to gather role assignments" -Type "Error"
}

Try {
    Write-log -Message "Addming roles with PIM" -Type "Information"
    $Roles += (Get-MgRoleManagementDirectoryRoleEligibilitySchedule -All -ExpandProperty * | Select-Object id,principalId,directoryScopeId,roleDefinitionId,status,principal,@{n = "roleDefinition1";e = { $_.roleDefinition } })
    Write-log -Message "Added roles with PIM" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to add PIM roles" -Type "Error"
}

Try {
    Write-log -Message "Exporting all the information" -Type "Information"
    foreach ($Role in $Roles) {
        $Export_Report = [pscustomobject][ordered]@{
            "Principal"            = switch ($Role.principal.AdditionalProperties.'@odata.type') {
                '#microsoft.graph.user' { $Role.principal.AdditionalProperties.userPrincipalName }
                '#microsoft.graph.servicePrincipal' { $Role.principal.AdditionalProperties.appId }
                '#microsoft.graph.group' { $Role.principalid }
            }
            "PrincipalDisplayName" = $Role.principal.AdditionalProperties.displayName
            "PrincipalType"        = $Role.principal.AdditionalProperties.'@odata.type'.Split(".")[-1]
            "AssignedRole"         = $Role.roleDefinition1.displayName
            "AssignedRoleScope"    = $Role.directoryScopeId
            "AssignmentType"       = (& { if ($Role.status -eq "Provisioned") { "Eligible" } else { "Permanent" } })
            "IsBuiltIn"            = $Role.roleDefinition1.isBuiltIn
            "RoleTemplate"         = $Role.roleDefinition1.templateId
        }
        $Export_Report | Export-Csv -Path "C:\Temp\Export\Roles.csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
    Write-log -Message "Information Exported" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to Exposrt information" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

