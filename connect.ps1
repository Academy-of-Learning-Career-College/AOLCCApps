#connects to meshcentral
$meshdl = 'https://meshcentral.aolccbc.com/meshagents?id=4&meshid=eaNSaUNg66CJkWzUkwrDfr8bbkQONkS8GPaSZinTaOtttQPONMsjDiiLFpaKtLP$Cjqo7mhzMHTNrGGHFDa7zKvWjt3tpjvqB2WTtaNTPRv$Hk6wQLG0p4ctc@P5g9Agfy8H30vASwLE5WgW4Sg5irwYoutS7Q==&installflags=2'

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("$meshdl"))