#Printers to remove

$printers = @(
'ET788C7778983A'
'Student-Printer *HP DeskJet'
'Student-Printer'
'Student Printer'
'Langley Facilitator'
)

foreach ($printer in $printers) {
    
    $printerdata = Get-Printer $printer -ErrorAction SilentlyContinue
    Write-Host $printerdata.Name`n $printerdata.DriverName`n $printerdata.PortName
    
    Remove-Printer $printerdata.Name
    Remove-PrinterPort $printerdata.PortName
    Remove-PrinterDriver $printerdata.DriverName

}
Restart-Service Spooler