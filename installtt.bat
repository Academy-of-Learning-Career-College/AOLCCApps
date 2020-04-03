echo Installing Pre-Requisits
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command " [System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
choco install -y vcredist-all
choco install -y git
choco install -y dotnet3.5
echo Downloading Latest Files
%ProgramFiles%\Git\cmd\git.exe clone https://github.com/fireball8931/AOLCCApps c:\Typing\
c:\Typing\part2.bat
