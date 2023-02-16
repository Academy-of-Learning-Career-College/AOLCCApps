if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSyncNGSC' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSync' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;


$registryKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"

$username = "NT AUTHORITY\SYSTEM"

$acl = Get-Acl $registryKey
$permission = "ReadKey"
$accessRule = New-Object System.Security.AccessControl.RegistryAccessRule($username,'ReadKey','Allow')
$acl.SetAccessRule($accessRule)
Set-Acl $registryKey $acl

$accessRule = New-Object System.Security.AccessControl.RegistryAccessRule($username,'FullControl','Deny')
#$acl.SetAccessRule($accessRule)
$acl.RemoveAccessRule($accessRule)
Set-Acl $registryKey $acl



$acl = Get-Acl $registryKey
$acl | Format-List