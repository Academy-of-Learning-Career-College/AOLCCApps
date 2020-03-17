echo installing typing trainer
"%~dp0\typingtrainersetup_v1.68.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
copy "%~dp0\database.txt" "c:\program files (x86)\TypingTrainer\database.txt"
copy "%~dp0\database.txt" "c:\program files\TypingTrainer\database.txt"