function Get-ManagedCredential ($Tenant)
{	
	$credential = $null
	$credential = Get-StoredCredential -Target $Tenant
	#If credential is found, return it
	if ($credential){return $credential}
		#if the credential isn't found, ask to create it
	else {
		
		$createcredential = checkCreateCredentials
		#if createcredential = true
		if($createcredential -eq 0)
		{	
		New-ManagedCredential $Tenant
		Get-ManagedCredential $Tenant
		}
		#if createcredential isn't true
		elseif($createcredential -eq 1)
		{
				Write-Host("You have to create a Windows Generic credential before proceeding, read more about how to use it here:") -Fore Yellow
				Write-Host("https://sharepointrelated.com/2018/06/12/powershell-easy-secure-office365/") -Fore Yellow
				Write-Host("")
				$Tenant = Read-Host "Enter a valid Generic credential name"
				Get-ManagedCredential $Tenant		
		}
	}
}

function New-ManagedCredential ($credentialname)
{

do{$newcredential = Get-Credential -Message "Password please"}
until($newcredential)

New-StoredCredential -Target $credentialname -Credentials $newcredential -Type "Generic" -Persist "Enterprise"
}

function checkCreateCredentials{
	$title = "Credential $creds not found"
	$message = "It looks like credential $creds hasn't been added to the Credential Manager, do you want to create it now?`nYes - Creates a new generic credential.`nNo - Enter a new credential name"
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
	$choice = $host.UI.PromptForChoice($title,$message,$options,0)

	return $choice
	
}