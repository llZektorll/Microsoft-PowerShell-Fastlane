<# 
.DESCRIPTION 
    Add list of user to a Group in Active Directory
.NOTES 
    Vertsion:   1.0
    Author: Hugo Santos
    GitHub: https://github.com/llZektorll
    Creation Date: 2025-03-10
#>
$Global:ErrorActionPreference = 'Stop'
#Group Information
$AD_Group = 'MyGoup'
$User_List = (Import-Csv -Path 'C:\Temp\Users.csv' -Delimiter ',').User
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
}
CheckFilePath

Try{
    Write-Log -Message "Adding $($User_List.count) Users" -Type "Information"
    Foreach($Account in $User_List){
        $User_Account = Get-ADUser -Filter "$User -eq '$Account'" | Select-Object ObjectGUID
        If($User_Account){
            Add-ADGroupMember -Identity $AD_Group -Members $User_Account
        }Else{
            Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Warning"
            Write-Log -Message "Unable to add $($Account)" -Type "Warning"
        }
    }
    Write-Log -Message "Added all USers" -Type "Success"
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-Log -Message "Unable Add Users" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}