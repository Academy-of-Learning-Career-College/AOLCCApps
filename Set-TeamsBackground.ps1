# Script to copy companies teams backgrounds to users %appdata%\Microsoft\Teams\Backgrounds.
# Created by: Remy Kuster
# Website: www.iamsysadmin.eu
# Modified by: Remco Janssen (19-01-2021)
# Creation date: 13-01-2021

# Create variables

$sourcefile = "https://github.com/fireball8931/AOLCCApps/raw/master/aolccwallpaper.jpg" # Set the share and folder where you put the custom backgrounds
$outfile = "$Uploadfolder\aolccwallpaper.jpg"
$TeamsStarted = "$env:APPDATA\Microsoft\Teams"
$DirectoryBGToCreate = "$env:APPDATA\Microsoft\Teams\Backgrounds"
$Uploadfolder = "$env:APPDATA\Microsoft\Teams\Backgrounds\Uploads"
$Logfile = "$env:LOCALAPPDATA\Logs\BG-copy.log"
$Logfilefolder = "$env:LOCALAPPDATA\Logs"

# Create logfile and function

# Check if %localappdata%\Logs is present, if not create folder and logfile

if (!(Test-Path -LiteralPath $Logfilefolder -PathType container)) 
    {
    
        try 
            {
                New-Item -Path $Logfilefolder -ItemType Directory -ErrorAction Stop | Out-Null #-Force
                New-Item -Path $Logfilefolder -Name "BG-copy.log" -ItemType File -ErrorAction Stop | Out-Null #-Force

                Start-Sleep -s 10

            }

        catch 

            {
                Write-Error -Message "Unable to create directory '$Logfilefolder' . Error was: $_" -ErrorAction Stop    
            }

    "Successfully created directory '$Logfilefolder' ."

    }

else 

    {
        "Directory '$Logfilefolder' already exist"
    }

# Clear the logfile before starting

Clear-Content $Logfile

# Create the logwrite function

Function LogWrite
{
   Param ([string]$logstring)
   $Stamp = (Get-Date).toString("dd/MM/yyy HH:mm:ss")
    $Line = "$Stamp $logstring"
 
   Add-content $Logfile -value $Line
}

# Check if teams is started once before for current user

if ( (Test-Path -LiteralPath $TeamsStarted) ) 
    { 
        logwrite "Teams started once before by the current user."
    }

else

    {
        logwrite "Teams has never been started by user"
        Exit 1
    }

# Check if %appdata%\Microsoft\Teams\Background is present, if not create folder

if (!(Test-Path -LiteralPath $DirectoryBGToCreate -PathType container)) 
    {
    
        try 
            {
                New-Item -Path $DirectoryBGToCreate -ItemType Directory -ErrorAction Stop | Out-Null #-Force
            }
        catch 
            {
                Write-Error -Message "Unable to create directory '$DirectoryBGToCreate' . Error was: $_" -ErrorAction Stop    
            }

    logwrite "Successfully created directories '$DirectoryBGToCreate' ."
    }

else 
    {
        logwrite "Directory '$DirectoryBGToCreate' already exist"
    }

# Check if %appdata%\Microsoft\Teams\Background\Uploads is present, if not create folder

if (!(Test-Path -LiteralPath $Uploadfolder -PathType container)) 
    {
    
        try 
            {
                New-Item -Path $Uploadfolder -ItemType Directory -ErrorAction Stop | Out-Null #-Force
            }
        catch 
            {
                Write-Error -Message "Unable to create directory '$Uploadfolder' . Error was: $_" -ErrorAction Stop    
            }

     logwrite "Successfully created directories '$Uploadfolder' ."
    }

else 
    {
        logwrite "Directory '$Uploadfolder' already exist"
    }

# Check if machine is connected to your corporate network

#$getoutput = (Test-Connection -ComputerName (hostname) -Count 1).IPV4Address.IPAddressToString # process active IP-address
#$getoutput = Get-NetIPAddress -AddressFamily IPv4 | Out-String -stream | Select-String -Pattern "IPAddress" # process IP-address list

# You can multiple adres ranges if your company has got vpn, wireless and physical different subnets. 
# This because we don't want to start the copy action from the share if the device is not connected to the corperate network.
        logwrite "Start copy action of uploads folder from share"
        Invoke-WebRequest -uri $sourcefile -outfile $outfile    
       

