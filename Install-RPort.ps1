[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url="https://pairing.rport.io/pmfPxw3"
Invoke-WebRequest -Uri $url -OutFile "rport-installer.ps1"
powershell -ExecutionPolicy Bypass -File .\rport-installer.ps1 -x -r -i