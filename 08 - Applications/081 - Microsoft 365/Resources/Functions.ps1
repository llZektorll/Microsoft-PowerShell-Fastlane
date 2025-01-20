#Sync with GitHub version
Function Sync-Update {
    If ($Sync.ProcessRunning -eq $false) {
        #Question user to check for updates
        $Check_Updates = [System.Windows.MessageBox]::Show("Do you want to check for updates", "MPFL - M365", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
        If ($Check_Updates -match "Yes") {
            #Link to Repository
            $GitHub_File = "https://raw.githubusercontent.com/llZektorll/Microsoft-PowerShell-Fastlane/refs/heads/main/08%20-%20Applications/081%20-%20Microsoft%20365/Main.ps1"
            try {
                # Fetch the file from GitHub
                $GitHub_File_Control = Invoke-WebRequest -Uri $GitHub_File -UseBasicParsing
                # Split the content into lines
                $GitHub_File_Control = $GitHub_File_Control.Content -split "`n"
                # Split the 5th line (index 4) by spaces and get the last value
                $GitHub_File_Version = ($GitHub_File_Control[4] -split " ")[-1]
            } catch {
                Write-Host "Failed to fetch the file from GitHub."
                return
            }
            # Compare versions and update if needed
        
            if ($GitHub_File_Version -match $Sync.Version) {
                [System.Windows.MessageBox]::Show("Running the latest version", "MPFL - M365", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
            } else {
                $GitHub_File = Invoke-WebRequest -Uri $GitHub_File -UseBasicParsing
                $GitHub_File.Content | Set-Content -Path $Sync.PSScriptRoot -Force -Encoding UTF8
            }
        } Else {
            Continue
        }
    }
}

#Log manager
Function Write-Log{
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Message,
        [Parameter(Mandatory=$true)]
        [String]$Type
    )
    $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Log = "$Date - $Type - $Message"
    $Log | Out-File -FilePath "$Log_Dir\$(Get-Date -Format "yyyy-MM-dd").log" -Append -NoClobber -Encoding utf8
}

# Text box configuration
Function TextBox{
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Name,
        [Parameter(Mandatory=$true)]
        [String]$Text,
        [Parameter(Mandatory=$true)]
        [Int]$X,
        [Parameter(Mandatory=$true)]
        [Int]$Y,
        [Parameter(Mandatory=$true)]
        [Int]$Width,
        [Parameter(Mandatory=$true)]
        [Int]$Height
    )
    $TextBox = New-Object System.Windows.Forms.TextBox
    $TextBox.Name = $Name
    $TextBox.Text = $Text
    $TextBox.Location = New-Object System.Drawing.Point($X, $Y)
    $TextBox.Width = $Width
    $TextBox.Height = $Height
    $TextBox
    $GUI.Controls.Add($TextBox)
    Return $TextBox
}

# Check box configuration
Function CheckBox{
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Name,
        [Parameter(Mandatory=$true)]
        [String]$Text,
        [Parameter(Mandatory=$true)]
        [Int]$X,
        [Parameter(Mandatory=$true)]
        [Int]$Y,
        [Parameter(Mandatory=$true)]
        [Int]$Width,
        [Parameter(Mandatory=$true)]
        [Int]$Height
    )
    $CheckBox = New-Object System.Windows.Forms.CheckBox
    $CheckBox.Name = $Name
    $CheckBox.Text = $Text
    $CheckBox.Location = New-Object System.Drawing.Point($X, $Y)
    $CheckBox.Width = $Width
    $CheckBox.Height = $Height
    $CheckBox
    $GUI.Controls.Add($CheckBox)
    Return $CheckBox
}

# Get all checkboxes that are selected
Function Get-SelectedCheckBoxes{
    $Button = New-Object System.Windows.Forms.Button
    $Button.Text = "Apply Configuration"
    $Button.Location = New-Object System.Drawing.Point(50, 50)
    $Gui.Controls.Add($Button)
}