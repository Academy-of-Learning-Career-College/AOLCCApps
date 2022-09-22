$FileAssoc = 'SOFTWARE\Classes\.pdf\OpenWithProgids'

$users = Get-ChildItem -Path registry::HKEY_USERS

$app = 'AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723'

foreach ($user in $users) {
try {
    Get-ItemProperty -Path "registry::$user\$FileAssoc" # -ErrorAction SilentlyContinue
}
catch {
    {1:<#Do this if a terminating exception happens#>}
}


}