

#Get Disk Size and report
#ifttt
$webhook="https://maker.ifttt.com/trigger/computerspec/with/key/mi-aXAV80-ySPPFnWmDVGeOr62eW3bYYu_nkpJl6N0I?"
#test url
#$webhook="https://n8n.langley.aolccbc.com/webhook-test/61bff564-95e2-470e-8871-d85010369268?"
#production
#$webhook="https://n8n.langley.aolccbc.com/webhook/61bff564-95e2-470e-8871-d85010369268?"
$drive = Get-CimInstance -Class Win32_LogicalDisk | Select-Object * | Where-Object DriveType -EQ '3'
$printerinstalled = 'printernotinstalled'
if(Get-Printer "*Canon Printer") {
    $printerinstalled = 'printerinstalled'
}

$size = [Math]::Round($drive.Size/1gb)
Write-Host My drive is $size GB
#$sn = Get-WmiObject win32_bios | select Serialnumber
$request = $webhook + 'value1=' + $drive.SystemName + "&value2=" + $size + "&value3=" + $printerinstalled

curl $request 
#-u miken:XEKj7fd9gDenCjoDn6TL