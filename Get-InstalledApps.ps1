# Get a list of all installed programs
$installedPrograms = Get-WmiObject -Class Win32_Product | Select-Object -Property Name, InstallDate

# Loop through each installed program
foreach ($program in $installedPrograms) {
  # Get the program's name and installation date
  $programName = $program.Name
  $installDate = $program.InstallDate

  # Use winget to search for the program and try to find its installation command
  $wingetResult = winget search $programName
  if ($null -ne $wingetResult) {
    $installCommand = $wingetResult | Select-Object -ExpandProperty InstallCommand
    Write-Host "$programName was installed on $installDate and can be installed with the following command: $installCommand"
  } else {
    Write-Host "$programName was installed on $installDate but no installation command could be found in winget."
  }
}
