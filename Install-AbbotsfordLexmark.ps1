$printername = 'Student Lexmark Printer'
$drivername = 'Lexmark Printer Software G4 HBP'
$printerIP = '192.168.1.233'
$driverlocation = '\\192.168.1.229\ttdata\drivers'
$driversearch = $driverlocation + '\LexmarkPkgInstaller.exe'
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
    