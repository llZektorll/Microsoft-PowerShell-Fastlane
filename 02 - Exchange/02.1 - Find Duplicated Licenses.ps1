<# 
.DESCRIPTION 
    Find duplicated licenses assigned to users
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-02-28
#>
If ([Net.SecurityProtocolType]::Tls12 -bor $False) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "`t Forced TLS 1.2 since its not server default"
}
$Global:ErrorActionPreference = 'Stop'
#connection
$Tenant_ID = 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1'
$Application_ID = 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1'
$Certificate_Thumb_Print = 'H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1H1'

#Initialize a report list
$Duplicate_Licenses_Report = @()
#Log Function
Function Write-Log {
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Message,
        [Parameter(Mandatory = $true)]
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
    Break
}

Try {
    #Get All users
    Try {
        Write-log -Message "Getting all Users" -Type "Information"
        $Users = Get-MgUser -All 
        Write-log -Message "Found $($Users.Count) users" -Type "Sucess"
    } Catch {
        Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
        Write-log -Message "Unable to get users" -Type "Error"
        Break
    }
    #For each user check if there are more than one licesses for the same application

    Foreach ($User in $Users) {
        Try {
            $Licenses = (Get-MgUserLicenseDetail -UserId $User.Id).SkuPartNumber
            If ($Licenses) {
                #Find duplicated
                $Duplicate_Licenses = $Licenses | Group-Object | Where-Object { $_.Count -gt 1 }
    
                If ($Duplicate_Licenses) {
                    Foreach ($Duplicated in $Duplicate_Licenses) {
                        $Duplicate_Licenses_Report += [PSCustomObject]@{
                            UserPrincipalName = $user.UserPrincipalName
                            DisplayName       = $user.DisplayName
                            DuplicateLicense  = $duplicate.Name
                            Count             = $duplicate.Count
                        }
                    }
                }
            }
        } Catch {
            Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
            Write-log -Message "Unable to get the user $($User.UserPrincipalName)" -Type "Error"
            Continue
        }
    }
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
}

Try {
    Write-log -Message "Exporting user with duplicated licenses" -Type "Information"
    If ($Duplicate_Licenses_Report.Count -gt 0) {
        $Duplicate_Licenses_Report | Export-Csv -Path "C:\Temp\Export\0021 - Find_Duplicated_Licenses_Export - $(Get-Date -Format 'yyyy-MM-dd').csv" -NoClobber -NoTypeInformation -Encoding UTF8 -
    }
    Write-log -Message "Information exported" -Type "Sucess"
} Catch {
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to export" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}

