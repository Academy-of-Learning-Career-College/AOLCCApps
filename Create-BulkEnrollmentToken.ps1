# Get the access token

Get-AADIntAccessTokenForAADGraph -Resource urn:ms-drs:enterpriseregistration.windows.net -SaveToCache

# Create a new BPRT

$bprt = New-AADIntBulkPRTToken -Name "BPRT"



Get-AADIntAccessTokenForAADJoin -BPRT $BPRT -SaveToCache
Write-Host $bprt

Set-Clipboard -Value $bprt
Write-Host BPRT added to clipboard. Please replace in Windows Configuration Designer