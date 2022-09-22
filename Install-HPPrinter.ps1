$printername = 'HP DeskJet 3630'
$drivername = 'HP DeskJet 3630 series'
#$printerIP = '192.168.2.234'
$driverlocation = $PSScriptRoot + '\drivers'
$driversearch = $driverlocation + '\hpygid20.inf'
$PrinterDetails = Get-Printer -Name $printername -ErrorAction SilentlyContinue

$printerIP = Read-Host -Prompt "Please enter the HOSTNAME of the printer"
if(!$printerIP) {
$printerIP = "HPA65D25"
}

if(!$PrinterDetails) {
    if (!(Get-PrinterDriver -Name $drivername -ErrorAction SilentlyContinue)){

        pnputil.exe /add-driver $driversearch
        Add-PrinterDriver -Name $drivername
    }
    if(!(Get-PrinterPort -Name $printerIP -ErrorAction SilentlyContinue)) {
        Add-PrinterPort -Name $printerIP -PrinterHostAddress $printerIP
    }  

    Add-Printer -Name $printername -PortName $printerIP -DriverName $drivername
    }
    
