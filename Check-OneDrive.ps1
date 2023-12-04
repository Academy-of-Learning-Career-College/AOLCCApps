try {if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")){ return $false };

if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSyncNGSC' -ea SilentlyContinue) -eq 0) {  } else { return $false };

if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSync' -ea SilentlyContinue) -eq 0) {  } else { return $false };

}catch { return $false };

return $true
