############
###Config###
############

$printername = 'Canon Printer' #Printer Name
$abbwan = '66.183.152.124'
$lawan = '66.183.1.50'

#test - pretent to be in langley
#$lawan = $abbwan
#$abbwan = ''

#In Abbotsford
if((Invoke-WebRequest https://ifconfig.me/ip).Content -eq $abbwan) {
    $printerIP = '192.168.1.245'
    $smbserver = '\\192.168.1.229'
    $printername = 'Abbotsford ' + $printername
    #$driverlocation = '\\192.168.1.229\ttdata\drivers'
} 
#In Langley
elseif((Invoke-WebRequest https://ifconfig.me/ip).Content -eq $lawan) {
    $printerIP = '192.168.2.245'
    $smbserver = '\\192.168.2.230'
    $printername = 'Langley ' + $printername
    #$driverlocation = '\\192.168.2.230\ttdata\drivers'
}
#Off Site
else {
    stop
}

$drivername = 'Canon Generic PCL6 Driver' #Driver from .inf file
$driverlocation = $smbserver + '\ttdata'
$driversearch = $driverlocation +'\drivers\GPCL6_Driver_V311_W64_00\Driver\CNP60MA64.INF' #INF file
$smbuser = 'smbguest' #SMB Username
$smbpassword = 'password' #SMB Password

###################
###Actual Script###
###################
#Test to see if the printer is installed already

if(!(Get-Printer $printername -ErrorAction SilentlyContinue)) {
    #Check for the driver and install if needed
    if (!(Get-PrinterDriver -Name $drivername -ErrorAction SilentlyContinue)){
        New-SmbMapping -RemotePath $driverlocation -UserName $smbuser -Password $smbpassword
        pnputil.exe /add-driver $driversearch
        Add-PrinterDriver -Name $drivername
    }

    #Check for the port and add if needed
    if(!(Get-PrinterPort -Name $printerIP -ErrorAction SilentlyContinue)) {
    Add-PrinterPort -Name $printerIP -PrinterHostAddress $printerIP
    }
    
    #Actually Add the printer
    Add-Printer -Name $printername -PortName $printerIP -DriverName $drivername

}

#Change Driver to PCL
if (!(Get-PrinterDriver -Name $drivername -ErrorAction SilentlyContinue)){
        New-SmbMapping -RemotePath $driverlocation -UserName $smbuser -Password $smbpassword
        pnputil.exe /add-driver $driversearch
        Add-PrinterDriver -Name $drivername
        Add-Printer -Name $printername -PortName $printerIP -DriverName $drivername
    }
