#Instructions:
# Go to acme
# Reports > School Basic > Contract Status > "Include Sub-Schools", "Start Date = Last January", "End Date = Today", "Funding Source = (Select All)", "Status = (Select All)", "Format: Excel"
# Save as StudentContractStatusOfflineFull.csv in the same folder as this PS1 file.
# Run as AzureAD admin user

Connect-MgGraph

$groupId = "aa02f234-8dc5-42e1-baf9-98981cdb89a3"

$acme = Import-Csv -Path "StudentContractStatusOfflineFull.csv" | Sort-Object UserFullName,Status

$inactiveStudents = New-Object System.Collections.ArrayList

$acmeNoDupes = $acme | Group-Object -Property userid

$result = foreach ($userid in $acmeNoDupes) {

$status = 0

if ($userid.Count -gt 1) {
foreach ($contract in $userid.Group) {
if ($contract.ContractCode -notcontains "CPL"){
#Write-Host $contract.ContractCode $contract.status


if ($contract.status -eq "In Progress") {
#Write-Host $contract.status
$status = 1
}
}
}

} else {
if ($userid.Group[0].status -eq "In Progress") {
$status = 1

}
}

if ($status -ne 1) {

$inactiveStudents.Add([pscustomobject]@{
   DisplayName=$userid.Group[0].UserFullName
   Status=$status
})

} 
} 
 

$inactiveStudents | Out-GridView




$members = Get-MgGroupMember -GroupId $groupId -All



$licensed = foreach ($member in $members) {

Get-MgUser -userid $member.id


}

foreach ($user in $licensed) {
$userstoRemove = $inactiveStudents | where {$_.DisplayName -eq $user.DisplayName.Trim("1234560")} | Select DisplayName
if ($userstoRemove) {
#Write-Host $userstoRemove.DisplayName
$search = $userstoRemove.DisplayName
$mguser = Get-MgUser -Search "displayName:$search" -ConsistencyLevel eventual | Select Id
foreach ($mguserID in $mguser) {
$id = $mguserID.Id
Remove-MgGroupMemberByRef -GroupId $groupId -DirectoryObjectId $id
}
}

#Remove-MgGroupMemberByRef -GroupId $groupId -DirectoryObjectId $remove.Id -WhatIf
}


