# Get the current DNS client settings
$dnsClientSettings = Get-DnsClient

# Get the search domain from the DNS client settings
$searchDomain = $dnsClientSettings[0].ConnectionSpecificSuffix

# Print the search domain
Write-Host "The search domain is: $searchDomain"
