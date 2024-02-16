<#
.SYNOPSIS
This script sets up a non-staff PC by installing necessary applications, configuring settings, and creating URL shortcuts.

.DESCRIPTION
The script performs the following actions:
- Installs required applications if not present (Visual C++ Redistributable 2010 x86, .NET 3.5, ACM Pro, and Typing Trainer).
- Configures Typing Trainer for campus use based on the computer's location.
- Creates URL shortcuts on the public desktop.

#>

# Function to create a shortcut

# GLOBALS
$gh = 'https://raw.githubusercontent.com/Academy-of-Learning-Career-College/AOLCCApps/master/Typing'

function CreateShortcut {
    param (
        [string]$Target,
        [string]$IconFile,
        [string]$Name,
        [string]$Folder,
        [string]$IconIndex = "0"
    )

    # Create the folder if it does not exist
    if (-not (Test-Path -Path $Folder)) {
        New-Item -Path $Folder -ItemType Directory
        Write-Host "Folder created: $Folder"
    }

    try {
        $FileName = "$Name.URL"
        $shortcutPath = Join-Path $Folder $FileName

        Set-Content -Path $shortcutPath -Value "[InternetShortcut]"
        Add-Content -Path $shortcutPath -Value "URL=$Target"
        Add-Content -Path $shortcutPath -Value "IconFile=$IconFile"
        Add-Content -Path $shortcutPath -Value "IconIndex=$IconIndex"
        Write-Host "Shortcut created successfully at: $shortcutPath"
    } catch {
        Write-Error "An error occurred while creating the shortcut: $_"
    }
}

# Function to download and install applications
function InstallApplications {
    $domain = "pub-ba40a2c327284ac787fcf7379eaa7030.r2.dev"
    $apps=@(
        @{Exe="vcredist_x86.exe";DetectFile="C:\Windows\SysWOW64\msvcp100.dll"},
        @{Exe="acmepro.2011.setup.v216.1.exe";DetectFile="C:\Program Files (x86)\ACMEPro2011\ACME.exe"},
        @{Exe="typingtrainersetup_v1.68.exe";DetectFile="C:\Program Files (x86)\TypingTrainer\TypingTrainer.exe"}
    )
    $appUrls = @(
        "https://$domain/$($apps[0].Exe)",
        "https://$domain/$($apps[1].Exe)",
        "https://$domain/$($apps[2].Exe)"
    )
    $installArgs = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-"

    # Install Visual C++ Redistributable 2010 x86
    try {
        $vcredistInstalled = Test-Path "C:\Windows\SysWOW64\msvcp100.dll"
        if (!$vcredistInstalled) {
            Write-Host "Installing Visual C++ Redistributable 2010 x86..."
            $vcredistPath = Join-Path $env:TEMP "vcredist_x86.exe"
            Invoke-WebRequest -Uri $appUrls[0] -OutFile $vcredistPath -UseBasicParsing
            Start-Process -FilePath $vcredistPath -ArgumentList "/q" -Wait
            Remove-Item $vcredistPath
            Write-Host "Visual C++ Redistributable 2010 x86 installed."
        }
    } catch {
        Write-Error "Failed to install Visual C++ Redistributable 2010 x86: $_"
    }

    # Activate .NET 3.5
    try {
        $net35Enabled = (Get-WindowsOptionalFeature -Online -FeatureName "NetFx3").State -eq "Enabled"
        if (!$net35Enabled) {
            Write-Host "Activating .NET 3.5..."
            Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart
            Write-Host ".NET 3.5 activated."
        }
    } catch {
        Write-Error "Failed to activate .NET 3.5: $_"
    }
    $leIndex=1    
    # Install ACME Pro and Typing Trainer
    foreach ($app in $apps[1..2]) {
        try {
            $appUrl = "https://" + $domain + "/" + $app.Exe
            $appExeName = [System.IO.Path]::GetFileNameWithoutExtension($appUrl)
            $appInstalled = Test-Path $app.DetectFile
            if (!$appInstalled) {
                Write-Host "Installing $appExeName..."
                $appPath = Join-Path $env:TEMP $app.Exe
                Invoke-WebRequest -Uri $appUrl -OutFile $appPath -UseBasicParsing
                Start-Process -FilePath $appPath -ArgumentList $installArgs -Wait
                Remove-Item $appPath
                Write-Host "$appExeName installed."
            $leIndex++
            }
        } catch {
            Write-Error "Failed to install ${appExeName}: $_"
        }
    }
}
function Test-RunningAsSystem {
    [CmdletBinding()]
    param()
    process{
        return ($(whoami -user) -match "S-1-5-18")
    }
}
# Function to configure Typing Trainer for campus use
function ConfigureTypingTrainerForCampusUse {
    param (
        [string]$Location,
        [string]$ScriptingDir,
        [string]$ProgFiles
    )

    # Verify Location
    if ($Location -eq 'OffSite'){
        return
    }
    if (!(Test-RunningAsSystem)){
        Write-Host "Although this computer is at the $Location campus, it appears as you are running this script in the user session"
        Write-Host "Therefore, I am assuming you are configuring a student's personal computer. Skipping Campus Config"
        return
    }
    # Is at a campus
    Write-Host "This computer is at the $Location campus."
    Write-Host "Configuring computer for campus use"

    # Set Firewall
    $net = Get-NetConnectionProfile
    try {
        Set-NetConnectionProfile -Name $net.Name -NetworkCategory Private
    }
    catch {
        Write-Error "There was an issue setting the firewall location"
    }

    # Configure Typing Trainer for Campus Database
    # Source Root
    
    # Source With location
    $src = "$gh/$Location"

    # Connection Script
    $conScript = 'connect.bat'
    $conScriptSrc = "$src/$conScript"
    $conScriptDest = Join-Path $ScriptingDir $conScript
    Invoke-WebRequest -Uri $conScriptSrc -OutFile $conScriptDest -UseBasicParsing

    # TypingTrainer Script
    $ttScript = "typingtrainer.bat"
    $ttScriptSrc = "$src/$ttScript"
    $ttScriptDest = Join-Path $ScriptingDir $ttScript
    Invoke-WebRequest -Uri $ttScriptSrc -OutFile $ttScriptDest -UseBasicParsing

    # Typing Trainer App Folder
    $ttProgDir = Join-Path $ProgFiles "TypingTrainer"
    

    #submit Results File

    # Database file
    $dbSrc = "$src/database.txt"
    $dbDest = Join-Path $ttProgDir "database.txt"
    # Remove old one just in case
    if(Test-Path $dbDest){
        Remove-Item -Path $dbDest -Force
    }
    Invoke-WebRequest -Uri $dbSrc -OutFile $dbDest -UseBasicParsing
}

function SetupTypingTrainerTasks {
    param (
        [string]$UploadWebhookUrl,
        [string]$CheckWebhookUrl,
        [string]$upn
    )

    # Pre-construct the argument strings with variable expansion for Invoke-RestMethod
    $UploadArgument = "-NoProfile -WindowStyle Hidden -Command ""Invoke-RestMethod -Uri '$($UploadWebhookUrl)' -Method Post -ContentType 'text/html' -InFile 'C:\ProgramData\TypingTrainer\type_results.html'"""
    $CheckArgument = "-NoProfile -WindowStyle Hidden -Command ""& { try { `$response = Invoke-RestMethod -Uri '$($CheckWebhookUrl)?upn=$($upn)' -UseBasicParsing -Method Get; if (`$response -ne 'Ok') { Unregister-ScheduledTask -TaskName 'TypingTrainerUpload' -Confirm:`$false; Unregister-ScheduledTask -TaskName 'CheckMicrosoftAccount' -Confirm:`$false } } catch { Unregister-ScheduledTask -TaskName 'TypingTrainerUpload' -Confirm:`$false; Unregister-ScheduledTask -TaskName 'CheckMicrosoftAccount' -Confirm:`$false } }"""


    # Main task to upload typing results
    $UploadAction = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $UploadArgument
    $UploadTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Friday -At 12pm
    $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -Action $UploadAction -Trigger $UploadTrigger -Principal $Principal -TaskName "TypingTrainerUpload" -Description "Upload Typing Trainer results every Friday at noon"

    # Checking task to monitor the Microsoft account's existence
    $CheckAction = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $CheckArgument
    $CheckTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(5) -RepetitionInterval (New-TimeSpan -Hours 24)
    Register-ScheduledTask -Action $CheckAction -Trigger $CheckTrigger -Principal $Principal -TaskName "CheckMicrosoftAccount" -Description "Check if Microsoft account exists and remove tasks if not"
}





# Main script execution
$homeDrive = "c:\"
if (!(Test-Path (Join-Path $homeDrive "staffpc"))) {
    $ScriptingDir = Join-Path $homeDrive "scriptfiles"
    if (!(Test-Path $ScriptingDir)) {
        New-Item -Path $ScriptingDir -ItemType Directory
        Write-Host "Created directory for script files: $ScriptingDir"
    }

    InstallApplications

    $publicDesktop = Join-Path $homeDrive "users\public\desktop"
    $defaultIcon = Join-Path $homeDrive "ssp.ico"
    $ProgFiles = Join-Path $homeDrive "Program Files (x86)"
        Remove-Item "$publicDesktop\*.lnk"
    Remove-Item "$publicDesktop\*.url"
    if((Test-RunningAsSystem)){
        $location = (Invoke-WebRequest -UseBasicParsing "http://ip.aolccbc.com/campus").Content
        
    } else {
        $location = 'OffSite'
        #setup upload shortcut
        # https://raw.githubusercontent.com/Academy-of-Learning-Career-College/AOLCCApps/master/Typing/submit_results.bat
        
        $uploadScript = 'submit_results.bat'
        $uploadScriptSrc = "$gh/$uploadScript"
        $uploadScriptDest = Join-Path $ScriptingDir $uploadScript
        Invoke-WebRequest -Uri $uploadScriptSrc -OutFile $uploadScriptDest -UseBasicParsing
        CreateShortcut -Folder $publicDesktop -Name "Submit Typing Results" -IconFile "$homeDrive\windows\system32\SHELL32.dll" -Target $uploadScriptDest -IconIndex "264"
        # Prompt the user for setup
        $setupAutoUpload = Read-Host "Do you want to setup auto uploading of typing results? (y/n)"

# if ($setupAutoUpload -eq "y") {
#     $schoolEmail = Read-Host "Please enter your school email address"
#     SetupTypingTrainerTasks -upn $schoolEmail -CheckWebhookUrl "https://n8n.aolccbc.com/webhook/6de9506e-2a0c-4cb5-9943-17f9bbbffcae" -UploadWebhookUrl "https://n8n.aolccbc.com/webhook/5d0245b1-67c6-4884-86d4-ca46f16ce67e"
# } else {
#     Write-Host "Auto upload setup skipped."
# }



    }



    if ($location -ne 'OffSite'){
        $ttShortcut = (Join-Path $ScriptingDir "typingtrainer.bat").Replace("\","/")
        ConfigureTypingTrainerForCampusUse -Location $location -ScriptingDir $ScriptingDir -ProgFiles $ProgFiles
    } else {
        $ttShortcut = (Join-Path $ProgFiles "TypingTrainer\TypingTrainer.exe").Replace("\","/")



        if(Test-Path -Path (Join-Path $ProgFiles "TypingTrainer\database.txt")){
            Write-Host "Typing Database file detected on Student Personal Computer"
            Write-Host "This will cause issues when they go home. Deleting database file"
            Remove-Item (Join-Path $ProgFiles "TypingTrainer\database.txt")
        }
    }
    



    Invoke-WebRequest -UseBasicParsing -Uri "https://i.aolccbc.com/favicon.ico" -OutFile $defaultIcon

    # Example of creating a shortcut
    # CreateShortcut -Folder $publicDesktop -Target "microsoft-edge:https://my.aolcc.com/"
    # Add more shortcut creation logic here as needed
    # [string]$Target,
    #     [string]$IconFile,
    #     [string]$Name,
    #     [string]$Folder
    $shortcuts = @(
        @{Target="microsoft-edge:https://my.aolcc.com/"; IconFile="$defaultIcon"; Name="SSP"},
        @{Target="microsoft-edge:https://acmeweb.academyoflearning.net/Forms/AttendanceLogin.aspx"; IconFile="$(Join-Path $ProgFiles "ACMEPro2011\ACMEManager.exe")"; Name="Legacy Students Attendance Tracker"},
        @{Target="microsoft-edge:https://my.aolcc.ca"; IconFile="$(Join-Path $ProgFiles "ACMEPro2011\ACME.exe")"; Name="Legacy Students myAOLCC"},
        @{Target="file://$ttShortcut"; IconFile="$(Join-Path $ProgFiles "ACMEPro2011\ACME.exe")"; Name="Connect to TypingTrainer"}
    )
    foreach ($sc in $shortcuts){
        # Write-Host $sc.Name $sc.IconFile $sc.Target
        CreateShortcut -Folder $publicDesktop -Name $sc.Name -IconFile $sc.IconFile -Target $sc.Target
    }
    Write-Host "Setup completed."
} else {
    Write-Host "This script is designed for non-staff PCs. Exiting."
}



#download and install preset db

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Academy-of-Learning-Career-College/AOLCCApps/master/Typing/typingtrainer.mdb" -UseBasicParsing -OutFile "C:\programdata\TypingTrainer\typingtrainer.mdb"