

#Get Disk Size and report
$webhook="https://maker.ifttt.com/trigger/computerspec/with/key/mi-aXAV80-ySPPFnWmDVGeOr62eW3bYYu_nkpJl6N0I?"

$drive = Get-CimInstance -Class Win32_LogicalDisk | Select-Object * | Where-Object DriveType -EQ '3'

$size = [Math]::Round($drive.Size/1gb)

Write-Host My drive is $size GB

$request = $webhook + 'value1=' + $drive.SystemName + "&value2=" + $size

curl $request