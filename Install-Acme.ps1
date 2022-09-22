#Install ACME
$acmeversion = '215.4'
$acmedisplayversion = '2011.' + $acmeversion
$installfile = 'acmepro.2011.setup.v' + $acmeversion + '.exe'
$url = 'https://aolccbc.com/downloads/' + $installfile
$dllocation = 'c:\scriptfiles' + $installfile
$uninstallstring = (Get-ItemProperty -Path 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ACME*').UninstallString
if ((Get-ItemProperty -Path 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ACME*').DisplayVersion -ne $acmedisplayversion) {
    if ([string]::IsNullOrEmpty($uninstallstring)) {
    start -FilePath (Get-ItemProperty -Path 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ACME*').UninstallString -ArgumentList '/QUIET'
}
    wget -uri $url -OutFile $installfile
    start -FilePath $installfile -ArgumentList '/SP- /VERYSILENT /SUPPRESSMSGBOXES /ALLUSERS /FORCECLOSEAPPLICATIONS /NOICONS'
}