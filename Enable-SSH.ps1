Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.S*' | Add-WindowsCapability -Online
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'