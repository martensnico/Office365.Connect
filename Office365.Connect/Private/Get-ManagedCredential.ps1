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

do{$newcredential = Get-Credential -Message "Enter a username / password for your tenant, so we can use this the next time you connect to your tenant automatically!"}
until($newcredential)

New-StoredCredential -Target $credentialname -Credentials $newcredential -Type "Generic" -Persist "Enterprise"
}

function checkCreateCredentials{
	$title = "Credential for tenant: $Tenant not found"
	$message = "It looks like this is the first time you are connecting to tenant: $Tenant. do you want to save your credentials for this tenant?`n`nYes - Creates a new generic credential for this tenant.`nNo - If you made a typo and want to retype your tenant name`n "
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
	$choice = $host.UI.PromptForChoice($title,$message,$options,0)

	return $choice
	
}