<# 
.DESCRIPTION 
    Massively search GitHub for KeyWords
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
# Define search keywords
$Search_Keywords = @(
    "Microsoft 365",
    "Windows"
)

# GitHub API URL
$GitHub_Api_Url = "https://api.github.com/search/repositories?q="

# Initialize an array to store results
$Repo_List = @()
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
    Write-log -Message "Loop through Keywords to fetch repositories and export to a CSV" -Type "Information"
    foreach ($Keyword in $Search_Keywords) {
        $Encoded_Keyword = [uri]::EscapeDataString($Keyword)
        $Url = "$GitHub_Api_Url$Encoded_Keyword&per_page=100&page=1"
        
        # Make API request
        $Response = Invoke-RestMethod -Uri $Url -Method Get -Headers @{"User-Agent" = "PowerShell"}
        
        # Process each Repository
        foreach ($Repo in $Response.items) {
            $Repo_Info = [PSCustomObject]@{
                "Repository Name" = $Repo.name
                "Description" = $Repo.description
                "Repository URL" = $Repo.html_url
            }
            $Repo_List += $Repo_Info
        }
        
        Start-Sleep -Seconds 5 # To avoid rate-limiting
    }
    $Repo_List | Export-Csv -Path "C:\Temp\Export\GitHub_Query.csv" -Delimiter ',' -Encoding UTF8 -NoClobber -NoTypeInformation -Append -Force
    Write-log -Message "Information Exported" -Type "Sucess"
}Catch{
    Write-Host "`n`t$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log -Message "$($_.InvocationInfo.InvocationName) [Line:$($_.InvocationInfo.ScriptLineNumber)]: $($_.Exception.Message)" -Type "Error"
    Write-log -Message "Unable to get information" -Type "Error"
}
$input = Read-Host "Do you want to check the scripts repository? (Press 'n' to cancel)"
if ($input -ne "n") {
    Start-Process "https://github.com/llZektorll/Microsoft-PowerShell-Fastlane"
} else {
    break
}
