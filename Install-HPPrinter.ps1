$printername = 'Student Printer'
$drivername = 'HP DeskJet 3630 series'
$printerIP = '192.168.2.234'
$driverlocation = '\\192.168.2.230\ttdata\drivers'
$driversearch = $driverlocation + '\hpygid20.inf'
$smbuser = 'smbguest'
$smbpassword = 'password'

$PrinterDetails = Get-Printer -Name $printername -ErrorAction SilentlyContinue

if(!$PrinterDetails) {
    if (!(Get-PrinterDriver -Name $drivername -ErrorAction SilentlyContinue)){
        New-SmbMapping -RemotePath $driverlocation -UserName $smbuser -Password $smbpassword
        pnputil.exe /add-driver $driversearch
        Add-PrinterDriver -Name $drivername
    }
    if(!(Get-PrinterPort -Name $printerIP -ErrorAction SilentlyContinue)) {
        Add-PrinterPort -Name $printerIP -PrinterHostAddress $printerIP
    }  

    Add-Printer -Name $printername -PortName $printerIP -DriverName $drivername
    }
    