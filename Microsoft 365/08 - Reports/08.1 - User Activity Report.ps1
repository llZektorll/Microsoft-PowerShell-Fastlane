<# 
.DESCRIPTION 
    Export User activity 
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
$SPO_Sources = "https:\\mpfl-admin.onmicrosoft.com"

#Graph Variables
$Uri = "https://graph.microsoft.com/v1.0/reports/getOffice365ActiveUserDetail(period='D180')"
$UsersReport = @()
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
    Write-log -Message 'Connecting to PNP Online' -Type 'Information'
    Connect-PnPOnline -Url $SPO_Sources -Tenant $Tenant_ID -ClientId $Application_ID -Thumbprint $Certificate_Thumb_Print
    Write-log -Message 'Connected to PNP' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to connect' -Type 'Error'
    Break
}

Try {
    Write-log -Message 'Getting a token from PNP' -Type 'Information'
    $Token = Get-PnPAccessToken
    $Header = @{ Authorization = "Bearer $($Token)" }
    Write-log -Message 'Token saved' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to get the token' -Type 'Error'
}

Try {
    Write-log -Message 'Geting Active Users Details' -Type 'Information'
    $Active_Users = Invoke-RestMethod -Uri $Uri -Headers $Header -Method Get -ContentType 'application/json'
    #BUG remove the first 3 characters
    $Active_Users = $Active_Users.Substring(3)
    $Active_Users = $Active_Users | ConvertFrom-Csv
    $Active_Users | Export-Csv -Path "C:\Temp\Export\Active_Users_$(Get-Date -Format 'yyyy-MM-dd').csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    Write-log -Message 'Users gathered and exported' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to gather and export users' -Type 'Error'
}

Try {
    Write-log -Message 'Gathering and Exporting Last Sing-IN' -Type 'Information'
    $Uri = "https://graph.microsoft.com/beta/users?`$select=displayName,userprincipalname,signInActivity,createdDateTime,UserType&`$top=999"
    $Last_SingIN_Info = Invoke-RestMethod -Uri $Uri -Headers $Header -Method Get -ContentType 'application/json'
    Foreach ($User in $Last_SingIN_Info.Value) {
        If ($Null -ne $User.SignInActivity -and $Null -ne $User.SignInActivity.LastSignInDateTime) {
            $LastSignIn = Get-Date($User.SignInActivity.LastSignInDateTime) -Format g
            $DaysSinceSignIn = (New-TimeSpan $LastSignIn).Days
        } Else {
            # If no sig in data for this user is found
            $LastSignIn = ''
            $DaysSinceSignIn = ''
        }
        $ReportLine = [PSCustomObject] @{
            UPN             = $User.UserPrincipalName
            DisplayName     = $User.DisplayName
            ObjectId        = $User.Id
            Created         = Get-Date($User.CreatedDateTime) -Format g      
            LastSignIn      = $LastSignIn
            DaysSinceSignIn = $DaysSinceSignIn
            UserType        = $User.UserType 
        }
        $usersReport += $ReportLine
    }

    $NextLink = $Last_SingIN_Info.'@Odata.NextLink'
    While ($Null -ne $NextLink) {
        $Last_SingIN_Info = Invoke-RestMethod -Uri $NextLink -Headers $Header -Method Get -ContentType 'application/json'
        Foreach ($User in $Last_SingIN_Info.Value) {
            If ($Null -ne $User.SignInActivity -and $Null -ne $User.SignInActivity.LastSignInDateTime ) {
                $LastSignIn = Get-Date($User.SignInActivity.LastSignInDateTime) -Format g
                $DaysSinceSignIn = (New-TimeSpan $LastSignIn).Days

            } Else {
                # If no sig in data for this user is found
                $LastSignIn = ''
                $DaysSinceSignIn = ''
            }
            $ReportLine = [PSCustomObject] @{
                UPN             = $User.UserPrincipalName
                DisplayName     = $User.DisplayName
                ObjectId        = $User.Id
                Created         = Get-Date($User.CreatedDateTime) -Format g      
                LastSignIn      = $LastSignIn
                DaysSinceSignIn = $DaysSinceSignIn
                UserType        = $User.UserType 
            }
            $usersReport += $ReportLine
        }
        $NextLink = $Last_SingIN_Info.'@Odata.NextLink'
    }
    $usersReport | Export-Csv -Path "C:\Temp\Export\Last_SingIN_$(Get-Date -Format 'yyyy-MM-dd').csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    Write-log -Message 'Last Sing-IN Exported' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unablet to get and export last sing-in' -Type 'Error'
}
Disconnect-PnPOnline
Try {
    Write-log -Message 'Connecting to PowerBI' -Type 'Information'
    Connect-PowerBIServiceAccount -ServicePrincipal -ApplicationId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -Tenant $Tenant_ID
    Write-log -Message 'Connected to PowerBI' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to connect ' -Type 'Error'
    Break
}

Try {
    Write-log -Message 'Exporting PowerBI Activity Logs' -Type 'Information'
    for ($s = 0; $s -le $Days; $s++) {
        $Period_Start = $Day.AddDays(-$s)
        $Base = $Period_Start.ToString('yyyy-MM-dd')
        $Url = "https://api.powerbi.com/v1.0/myorg/admin/activityevents?startDateTime='$($Base)T00:00:00.000'&endDateTime='$($Base)T23:59:59.999'"
        $Activities = Invoke-PowerBIRestMethod -Url $Url -Method Get | ConvertFrom-Json
        $Activities = $Activities.activityEventEntities
        $Activities | Select-Object CreationTime,UserId | Export-Csv -Path "C:\Temp\Export\PowerBI_Activity_$(Get-Date -Format 'yyyy-MM-dd').csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    }
    Write-log -Message 'Activity exported' -Type 'Sucess'
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type 'Error'
    Write-log -Message 'Unable to export PowerBI Activity' -Type 'Error'
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}
