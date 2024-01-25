# Define the URI of the webhook
$Uri = "https://n8n.aolccbc.com/webhook/5d0245b1-67c6-4884-86d4-ca46f16ce67e"

# Define the headers
$Headers = @{
    "Content-Type" = "text/html"
}

# Define the path to the file you want to send
$FilePath = "C:\ProgramData\TypingTrainer\type_results.html"

# Read the content of the file
$Content = Get-Content -Path $FilePath -Raw

# Send the POST request with the binary content
Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $Content -ContentType "text/html"
