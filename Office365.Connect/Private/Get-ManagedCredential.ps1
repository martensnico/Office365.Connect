function Get-ManagedCredential ($creds)
{
	$credential = Get-StoredCredential -Target $creds
	if ($credential) { return $credential }
	else {
		do
		{
			Write-Host("You have to create a Windows Generic credential before proceeding, read more about how to use it here:") -Fore Red
			Write-Host("https://sharepointrelated.com/2018/06/12/powershell-easy-secure-office365/") -Fore Yellow
			Write-Host("")
			$creds = Read-Host "Enter a valid Generic credential name"
			$credential = Get-StoredCredential -Target $creds
		}
		until
		($credential)
	}
	return $credential
}