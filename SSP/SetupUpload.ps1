function SetupTypingTrainerTasks {
    param (
        [string]$UploadWebhookUrl,
        [string]$CheckWebhookUrl,
        [string]$upn
    )

    # Main task to upload typing results
    $UploadAction = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -Command ""curl -X POST -H 'Content-Type: text/html' --data-binary '@C:\ProgramData\TypingTrainer\type_results.html' '$UploadWebhookUrl'"""
    $UploadTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Friday -At 12pm
    $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -Action $UploadAction -Trigger $UploadTrigger -Principal $Principal -TaskName "TypingTrainerUpload" -Description "Upload Typing Trainer results every Friday at noon"

    # Checking task to monitor the Microsoft account's existence
    $CheckAction = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -Command ""& { `$response = curl -UseBasicParsing '$CheckWebhookUrl?upn'; if (`$response.StatusCode -ne 200) { Unregister-ScheduledTask -TaskName 'TypingTrainerUpload' -Confirm:`$false; Unregister-ScheduledTask -TaskName 'CheckMicrosoftAccount' -Confirm:`$false } }"""
    $CheckTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(5) -RepetitionInterval (New-TimeSpan -Hours 24)
    Register-ScheduledTask -Action $CheckAction -Trigger $CheckTrigger -Principal $Principal -TaskName "CheckMicrosoftAccount" -Description "Check if Microsoft account exists and remove tasks if not"
}

# To use the function, call it with the specific webhook URLs
# SetupTypingTrainerTasks -UploadWebhookUrl "https://n8n.aolccbc.com/webhook/upload" -CheckWebhookUrl "https://n8n.aolccbc.com/webhook/check"

$setupAutoUpload = Read-Host "Do you want to setup auto uploading of typing results? (y/n)"

if ($setupAutoUpload -eq "y") {
    $schoolEmail = Read-Host "Please enter your school email address"
    SetupTypingTrainerTasks -upn $schoolEmail -CheckWebhookUrl "https://n8n.aolccbc.com/webhook/6de9506e-2a0c-4cb5-9943-17f9bbbffcae" -UploadWebhookUrl "https://n8n.aolccbc.com/webhook/5d0245b1-67c6-4884-86d4-ca46f16ce67e"
} else {
    Write-Host "Auto upload setup skipped."
    return
}