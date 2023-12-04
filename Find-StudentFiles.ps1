# Define folder paths
$studentFolder = "C:\Users\mike\OneDrive - Academy of Learning\Abbotsford GDATA\!!!Student Archive"
$unsortedFolder = "C:\Users\mike\OneDrive - Academy of Learning\Abbotsford GDATA\Unsorted Files Bucket"

# Get all folder names recursively in student folder
$folders = Get-ChildItem $studentFolder -Directory -Recurse | Select-Object FullName

# Loop through each folder name
foreach ($folder in $folders) {
    # Get folder name without path
    $folderName = Split-Path $folder.FullName -Leaf
    
    # Search for files in unsorted folder that contain the folder name
    $searchResults = Get-ChildItem $unsortedFolder -Recurse | Where-Object {$_.FullName -match $folderName}
    
    if ($searchResults.Count -eq 0) {
        Write-Host "No files found for folder '$folderName'"
        continue
    }
    
    # Move each file into the matching folder
    foreach ($result in $searchResults) {
        Move-Item $result.FullName $folder.FullName
        
        # Log move to file
        Add-Content "move.log" "Moved $($result.Name) to $($folder.FullName)"
    }
}
