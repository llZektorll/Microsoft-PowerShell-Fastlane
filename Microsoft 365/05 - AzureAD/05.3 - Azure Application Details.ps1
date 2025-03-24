<# 
.DESCRIPTION 
    Get Azure App Details
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-18
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

#Initialize Variables
$i = 0
$Export_Details = [System.Collections.Generic.List[Object]]::new()
#Log Function
Function Write-Log {
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Message,
        [Parameter(Mandatory = $true)]
        [String]$Type
    )
    $Date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $Log = "$Date - $Type - $Message"
    $Log | Out-File -FilePath "C:\Temp\Log\$(Get-Date -Format 'yyyy-MM-dd').log" -Append -NoClobber -Encoding UTF8
}
# Export Location
Function CheckFilePath {
    If (Test-Path -Path 'C:\Temp\Log') {}Else {
        New-Item 'C:\Temp\Log' -ItemType Directory
    }
    If (Test-Path -Path 'C:\Temp\Export') {}Else {
        New-Item 'C:\Temp\Export' -ItemType Directory
    }
}
CheckFilePath

Function Get-ApiPermissions {
    # Retrieve API permissions (requiredResourceAccess)
    $App_Required_Resource_Access = $App.requiredResourceAccess
    $Delegated_Permissions = @()
    $Application_Permissions = @()

    Foreach ($ResourceAccess in $App_Required_Resource_Access) {
        $ServicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$($ResourceAccess.ResourceAppId)'"
        $ResourceName = $ServicePrincipal.DisplayName

        Foreach ($Access in $ResourceAccess.ResourceAccess) {
            Foreach ($Permission in $Permission) {
                If ($Permission.ResourceId -eq $Access.Id) {
                    Write-Host $Permission.Scope
                }
            }
        }
    }
    $Delegated_PermissionsString = $Delegated_Permissions -join ' | '
    $Application_PermissionsString = $Application_Permissions -join ' | '
}

Try {
    Write-log -Message 'Connect to Graph' -Type 'Information'
    Connect-MgGraph -ClientId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -TenantId $Tenant_ID -NoWelcome
    Write-log -Message 'Connected' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to connect' -Type 'Error'
    Break
}

Try {
    Write-log -Message 'Getting and sorting information' -Type 'Information'
    $Apps = Get-MgApplication -All
    $Permissions = Get-MgOauth2PermissionGrant -All
    Foreach ($App in $Apps) {
        $i++
        $App_Auth_Validation = Get-MgApplication -Filter "AppId eq '$($App.AppId)'" | Select-Object -ExpandProperty keyCredentials | Where-Object -Property Count -LT 0
        $App_Auth_Validation = ($App_Auth_Validation.endDateTime -join ' | ')
        Get-ApiPermissions $App.requiredResourceAccess
        $App_Permissions_Data = [PSCustomObject][ordered]@{
            'Number'                    = $i
            'Application Name'          = $App.DisplayName
            'ApplicationId'             = $App.AppId
            'Publisher'                 = $App.publisherDomain
            'Verified'                  = (& { if ($App.verifiedPublisher.verifiedPublisherId) { $App.verifiedPublisher.displayName } else { 'Not verified' } })
            'Certification'             = $App.certification
            'SignInAudience'            = $App.signInAudience
            'ObjectId'                  = $App.id
            'Created on'                = (& { if ($App.createdDateTime) { (Get-Date($App.createdDateTime) -Format g) } else { 'N/A' } })
            'Allow Public client flows' = (& { if ($App.isFallbackPublicClient -eq 'true') { 'True' } else { 'False' } })
            'Delegated Permissions'     = $Delegated_PermissionsString
            'Application Permissions'   = $Application_PermissionsString
            'Auth Validation'           = $App_Auth_Validation
        }
        $Export_Details.Add($App_Permissions_Data)
    }
    Write-log -Message 'Information retrieved' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to get information' -Type 'Error'
}

Try {
    Write-log -Message 'Export information' -Type 'Information'
    $Export_Details | Export-Csv -Path 'C:\Temp\Export\Azure App Details.csv' -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    Write-log -Message 'Information Exported' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to export information' -Type 'Error'
}
<#
$input = Read-Host 'Do you want to check the scripts repository? (Press 'n" to cancel)"
if ($input -ne 'n') {
    Start-Process 'https://github.com/llZektorll/Microsoft-PowerShell-Fastlane'
} else {
    break
}
#>