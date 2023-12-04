# To Run on a remote computer, run this command: 
# Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://s.aolccbc.com/Run-VDOT.ps1'))

$baseURL = "https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/heads/VDOT_v3.zip"


$targetDir = 'c:\vdot'

try {
    if(!(Test-Path $targetDir)){
        New-Item -ItemType Directory -Path $targetDir -Force
        # Set secure permissions for the directory
        $acl = Get-Acl $targetDir
        $acl.SetAccessRuleProtection($true, $false)
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule)
        Set-Acl -Path $targetDir -AclObject $acl
    }

    $zipFile = Join-Path $targetDir 'VDOT_v3.zip'
    if(!(Test-Path $zipFile)){
        # Download the file securely and validate SSL certificate
        Invoke-WebRequest -Uri $baseURL -OutFile $zipFile -UseBasicParsing -CertificateCheck
        Unblock-File $zipFile
        Expand-Archive -Path $zipFile -DestinationPath $targetDir
    }

    $VDOTPath = Join-Path (Get-ChildItem -Path $targetDir -Directory).FullName 'Windows_VDOT.ps1'
    if(Test-Path $VDOTPath){
        # Validate script integrity and execute securely
        $scriptContent = Get-Content -Path $VDOTPath -Raw
        if((Get-FileHash -Path $VDOTPath -Algorithm SHA256).Hash -eq "C1C4F959515B0CE55019D253EC4B881D32CB0959D260F6FDBF2A2163CD20028E"){
            Invoke-Expression $scriptContent -AcceptEula -Verbose -Optimizations Autologgers, DefaultUserSettings, DiskCleanup, NetworkOptimizations, ScheduledTasks, Services
        }
        else{
            Write-Host "VDOT script integrity check failed. Aborting execution."
        }
    }
    else{
        Write-Host "VDOT script not found."
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)"
}