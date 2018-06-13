function Connect-AAD
{
	if ($MFA)
	{
		Write-Host ("Connecting Azure Active Directory with MFA") -Fore Yellow
		try {
			Connect-AzureAD -AccountID $credential.userName | Out-Null
			Write-Host ("Successfully connected to Azure Active Directory with MFA") -Fore Green
		}
		catch { 
			Write-Host ($_.Exception.Message)
			Write-Host ("Could not connect to Azure Active Directory with MFA") 
			WaitAnyKey
		}
	}
	if (!$MFA)
	{
		Write-Host ("Connecting Azure Active Directory") -Fore Yellow
		try {
			Connect-AzureAD -Credential $credential | Out-Null
			Write-Host ("Successfully connected to Azure Active Directory") -Fore Green
		}
		catch { Write-Host ("Could not connect to Azure Active Directory") }
	}
}

function Connect-SPO
{
	if ($MFA)
	{
	Write-Host $($credential.UserName)
		Write-Host ("Connecting SharePoint Online with MFA") -Fore Yellow
		Set-Clipboard $credential.userName
		Write-Host ("Unfortunately, your username could not be added automatically. However, it was copied to your clipboard.")
		Write-Host ("Please hit Ctrl + V to paste your username")
		try {
			Connect-SPOService -URL "https://$($Tenant)-admin.sharepoint.com"
			Write-Host "Successfully connected to SharePoint Online with MFA" -Fore Green
		}
		catch
		{ Write-Host ("Could not connect to SharePoint Online with MFA") -Fore Red }
	}
	if (!$MFA)
	{
		Write-Host ("Connecting SharePoint Online") -Fore Yellow
		try {
			Connect-SPOService -URL "https://$($Tenant)-admin.sharepoint.com" -Credential $credential
			Write-Host "Successfully connected to SharePoint Online" -Fore Green
		}
		catch { 
		Write-Host ("Could not connect to SharePoint Online.") -Fore Red 
		Write-Host ("Make sure your Credential name matches your Office 365 tenant name.") -Fore Red
		Write-Host ("For instance: if credential name = contoso, the cmdlet will use https://contoso-admin.sharepoint.com as URL parameter") -Fore Red
		WaitAnyKey
		}
	}
}

function Connect-EXO
{
	if ($MFA)
	{
	Write-Host("Sorry, Exchange Online requires a separate module with MFA, which cannot be installed for you.") -Fore Yellow
	Write-Host("Find more about how to install it here:") -Fore Yellow
	Write-Host("")
	Write-Host("https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/mfa-connect-to-exchange-online-powershell?view=exchange-ps") -Fore Yellow
	WaitAnyKey
	}
	if (!$MFA)
	{
	Write-Host ("Connecting Exchange Online") -Fore Yellow
	try {
		$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
		Import-Module (Import-PSSession $exchangeSession -AllowClobber) -Global | Out-Null
		Write-Host ("Successfully connected to Exchange online") -Fore Green
		WaitAnyKey
	}
	catch { Write-Host ("Could not connect to Exchange Online with MFA") -Fore Red;WaitAnyKey }
	}
}

function Connect-S4B
{	
	if(Get-Module -ListAvailable -Name "SkypeOnlineConnector")
	{
	if ($MFA)
	{
	Write-Host ("Connecting Skype for Business Online with MFA") -Fore Yellow
	try {
		$sfboSession = New-CsOnlineSession -UserName $credential.UserName
		Import-Module (Import-PSSession $sfboSession) -Global | Out-Null
		Write-Host ("Successfully connected to Skype for Business Online with MFA") -Fore Green
		}
		catch {
		Write-Host ("Could not connect to Skype for Business Online with MFA") -Fore Red
		Write-Host ("Please try again after installing the Skype for Business Module. You can find it here:" ) -Fore Red
		Write-Host ("https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowerShell.Exe") -Fore Yellow
		WaitAnyKey 
		}
	}

	if (!$MFA)
	{
		Write-Host ("Connecting Skype for Business Online") -Fore Yellow
		try {
			$sfboSession = New-CsOnlineSession -Credential $credential
			Import-Module (Import-PSSession $sfboSession) -Global | Out-Null
			Write-Host ("Successfully connected to Skype for Business Online") -Fore Green
		}
		catch { 
			Write-Host ("Could not connect to Skype for Business Online") -Fore Red
			}
	}
}
else {
	Write-Host ("Please try again after installing the Skype for Business Module. You can find it here:") -Fore Red
	Write-Host ("https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowerShell.Exe") -Fore Yellow
	WaitAnyKey
}
}

function Connect-MSTeams
{
	if ($MFA)
	{
	Write-Host ("Connecting Microsoft Teams with MFA") -Fore Yellow
	try {
		Connect-MicrosoftTeams -AccountID $credential.UserName | Out-Null
		Write-Host ("Successfully connected to Microsoft Teams using MFA") -Fore Green
	}
	catch { Write-Host ("Could not connect to Microsoft Teams using MFA") -Fore Red }
	}
	if (!$MFA)
	{
	Write-Host ("Connecting Microsoft Teams") -Fore Yellow
	try {
		Connect-MicrosoftTeams -Credential $credential | Out-Null
		Write-Host ("Successfully connected to Microsoft Teams") -Fore Green
	}
	catch { Write-Host ("Could not connect to Microsoft Teams") -Fore Red }
	}
}

function Connect-SandC
{
	if ($MFA)
	{
	Write-Host("Sorry, Security & Compliance Center requires a separate module with MFA, which cannot be installed for you.") -Fore Yellow
	Write-Host("Find more about how to install it here:") -Fore Yellow
	Write-Host("")
	Write-Host("https://docs.microsoft.com/en-us/powershell/exchange/office-365-scc/connect-to-scc-powershell/mfa-connect-to-scc-powershell?view=exchange-ps") -Fore Yellow
	WaitAnyKey
	}
	if (!$MFA)
	{
	Write-Host ("Connecting Security & Compliance Center") -Fore Yellow
	try {
		$SccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication "Basic" -AllowRedirection
		Import-PSSession $SccSession -Prefix cc
		Write-Host ("Successfully connected to Security & Compliance Center") -Fore Green
	}
	catch { Write-Host ("Could not connect to Security & Compliance Center") -Fore Red }
	}
}

function Connect-PNP
{
	if ($MFA)
	{
	Write-Host ("Connecting PNP Online with MFA") -Fore Yellow
	try {
		Write-Host("What site collection do you want to connect to?`n")
		if(($result = Read-Host "Default value [https://$($Tenant).sharepoint.com]") -eq ''){$result = "https://$($Tenant).sharepoint.com"}else{}
		Connect-PnPOnline -URL $result -UseWebLogin
		Write-Host ("Successfully connected to PNP Online with MFA") -Fore Green
	}
	catch { Write-Host ("Could not connect to PNP Online, try again.") -Fore Red;WaitAnyKey }
	}
	if (!$MFA)
	{
	Write-Host ("Connecting PNP Online") -Fore Yellow
	try {
		Write-Host("What site collection do you want to connect to?`n")
		if(($result = Read-Host "Default value [https://$($Tenant).sharepoint.com]") -eq ''){$result = "https://$($Tenant).sharepoint.com"}else{}
		Connect-PnPOnline -URL $result -Credentials $credential
		Write-Host ("Successfully connected to PNP Online") -Fore Green
	}
	catch { Write-Host ("Could not connect to PNP Online, try again.") -Fore Red;WaitAnyKey }
	}
}

function Connect-MSOL
{
	if ($MFA)
	{
	Write-Host ("Connecting Microsoft Online with MFA") -Fore Yellow
		Set-Clipboard $credential.userName
		Write-Host ("Unfortunately, your username could not be added automatically. However, it was copied to your clipboard.")
		Write-Host ("Please hit Ctrl + V to paste your username")
	try {
		Connect-MsolService
		Write-Host ("Successfully connected to Microsoft Online") -Fore Green
	}
	catch { Write-Host ("Could not connect to Microsoft Online") -Fore Red }
	}
	if (!$MFA)
	{
	Write-Host ("Connecting Microsoft Online") -Fore Yellow
	try {
		Connect-MsolService -Credential $credential
		Write-Host ("Successfully connected to Microsoft Online") -Fore Green
	}
	catch { 
	Write-Host ("Could not connect to Microsoft Online") -Fore Red 
	WaitAnyKey
	}
	}
}
