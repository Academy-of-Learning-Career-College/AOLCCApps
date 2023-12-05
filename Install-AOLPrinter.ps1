function Send-TeamsMessage {
    param(
    [string]$log,
    [string]$message = "No message provided",
    [string]$logSnag = "https://api.logsnag.com/v1/log",
    [string]$project = "compliance",
    [string]$channel = "printer-installs",
    [string]$bearer = "1c8a95460002356bf509ff34ca60f35e"
    );
# NOTE: Bearer Token is only good for posting messages to the board. Nothing else.
    if ($message -eq "No message provide"){$message=''};

    $JSONBody = @{
        "project" = $project
        "channel" = $channel
        "event"=$message
        "description"=$log
        "icon" = ":printer:"
    }
    $TeamMessageBody = ConvertTo-Json $JSONBody -Depth 100;
    $parameters = @{
        "URI" = $logSnag;
        "Method" = 'POST';
        "Body" = $TeamMessageBody;
        "ContentType" = 'application/json';
        "Headers" = @{
            "Authorization" = "Bearer $bearer"
        }
    };

    Invoke-RestMethod @parameters
}

############
###Config###
############
$abbwan = '66.183.152.124'
$lawan = '66.183.1.50'
$subnet = "192.168"


# Checking if the current machine is in Abbotsford or Langley based on IP
switch ((Invoke-WebRequest https://ip.aolccbc.com).Content) {
    $abbwan {
        # In Abbotsford
        # $regfile = "AbbotsfordCanonStudentDefaults.reg"
        $printername = 'Abbotsford Canon Printer'
        $subnet += ".1"
        $smbserver = "$subnet.150"
    }
    $lawan {
        # In Langley
        $printername = 'Langley Canon Printer'
        $subnet += ".2"
        $smbserver = "$subnet.230"
    }
    default {
        Write-Error "Off Site: Exiting."
        Exit
    }
}


# Setting printer variables
$driverlocation = "\\$smbserver\ttdata\drivers"
$printerIP = "$subnet.245"
# Setting printer variables
$drivername = 'Canon Generic Plus PCL6'
$driversearch = Join-Path $driverlocation 'CNP60MA64.INF'
$smbcredential = New-Object System.Management.Automation.PSCredential('smbguest', (ConvertTo-SecureString 'password' -AsPlainText -Force))
$params = @{
    Name       = $printername
    PortName   = $printerIP
    DriverName = $drivername
}

# Adding a new printer
if (!(Get-Printer $printername)) {
    Try {
        # Install driver if required
        if (!(Get-PrinterDriver -Name $drivername)) {
            net use $driverlocation $null /user:$($smbcredential.UserName) $($smbcredential.GetNetworkCredential().Password)
            pnputil.exe /add-driver $driversearch
            Add-PrinterDriver -Name $drivername
        }

        # Add printer port if required
        if (!(Get-PrinterPort -Name $printerIP)) {
            Add-PrinterPort -Name $printerIP -PrinterHostAddress $printerIP
        }

        # Actually add the printer
        Add-Printer @params

    }
    Catch {
        # Error catching
        Write-Error $_.Exception.Message

        return $false
    }
} else {
    # Change printer driver if printer already exists
    Try {
        Set-Printer -Name $printername -DriverName $drivername
    }
    Catch {
        # Only executed if an error occurs
        Write-Error $_.Exception.Message
        return $false
    }
}

# Import registry file
# $regfile = Join-Path -Path $driverlocation -ChildPath $regfile
# if (Test-Path $regfile) {
#     regedit /s $regfile
#     Write-Host "Registry file imported successfully."
# } else {
#     Write-Error "Registry file not found at $regfile."
#     return $false
# }

# Set default printer configuration
Get-Printer *canon* | Set-PrintConfiguration -Color $False -PaperSize Letter

# Remove old printers
Write-host Removing Old Printers
$printersToRemove = @(
    'ET788C7778983A',
    'Student-Printer *HP DeskJet',
    'Student-Printer',
    'Student Printer',
    'Langley Facilitator',
    '*facil*',
    'Student Lexmark*',
    'Brother*'
)
foreach ($printer in $printersToRemove) {
    if (Get-Printer $printer -ErrorAction SilentlyContinue) {
        Remove-Printer $printer -EA SilentlyContinue
    }
}

# Remove WSD Devices
Write-Host Checking for WSD printers and removing
Get-Printer | Where-Object {$_.PortName -like 'WSD*'} | ForEach-Object {
    Write-Host "Removing $($_.Name)"
    Remove-Printer $_ -EA SilentlyContinue
}

Restart-Service Spooler
Write-Host Here are the currently installed printers
Get-Printer | Select-Object Name, PortName

if (! (Get-Printer $printername -ErrorAction SilentlyContinue)) {
    Write-Host "Printer $printername installation failed."
    return $false
} else {

    Send-TeamsMessage -message "Printer was installed on $ENV:COMPUTERNAME"
    Write-Host "Printer installation was successful."
    return $true
}


