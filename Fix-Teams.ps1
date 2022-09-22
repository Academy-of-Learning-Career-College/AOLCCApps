Get-Process -Name Teams |Stop-Process
Get-ChildItem -Path $env:appdata\Microsoft\Teams -Recurse |Remove-item -Recurse