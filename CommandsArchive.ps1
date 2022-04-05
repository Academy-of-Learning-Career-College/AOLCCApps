if((Test-Path -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{BBC7F69B-7A94-41E9-8A4B-B55A8D06431F}\') -eq $true) { 
    $uninstallstring1 = Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{BBC7F69B-7A94-41E9-8A4B-B55A8D06431F}\' -Name 'UninstallString'
    wget -Uri https://www.aolccbc.com/downloads/oldversions.iss -Outfile 'c:\scriptfiles\oldversions.iss'
    cmd /c $uninstallstring1.UninstallString -s -f1'c:\scriptfiles\oldversions.iss'
    }
    
    if((Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{EEDFE0FF-CB95-46D9-9050-F768B126ABDB}\' -Name 'InstallDate').InstallDate -lt '20210423') {
        $uninstallstring1 = Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{EEDFE0FF-CB95-46D9-9050-F768B126ABDB}\' -Name 'UninstallString'
        wget -Uri https://www.aolccbc.com/downloads/oldversions.iss -Outfile 'c:\scriptfiles\oldversions.iss'
        cmd /c $uninstallstring1.UninstallString -s -f1'c:\scriptfiles\oldversions.iss' 
    }
    
    if((Test-Path -Path 'C:\Program Files (x86)\InstallShield Installation Information\{EEDFE0FF-CB95-46D9-9050-F768B126ABDB}\setup.exe') -eq $false) { 
    wget -Uri 'https://www.aolccbc.com/downloads/LockDown20701.zip' -Outfile 'c:\scriptfiles\LockDown20701.zip'
    cd c:\scriptfiles
    Expand-Archive -Path 'c:\scriptfiles\LockDown20701.zip' -Force
    wget -Uri 'https://www.aolccbc.com/downloads/ldbsetup.iss' -Outfile 'c:\scriptfiles\LockDown20701\setup.iss'
    cmd /c 'c:\scriptfiles\LockDown20701\setup.exe' -s -f1'c:\scriptfiles\LockDown20701\setup.iss'
    }