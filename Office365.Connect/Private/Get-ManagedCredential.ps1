function Get-ManagedCredential ($creds)
{
	$credential = Get-StoredCredential -Target $creds
	if ($credential) { return $credential }
	else {
		do
		{
			$creds = Read-Host "Couldn't find credential in Windows Generic Credentials, please try again"
			$credential = Get-StoredCredential -Target $creds
		}
		until
		($credential)
	}
	return $credential
}