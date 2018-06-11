<#*********************************************

Published at: https://powershellgallery.com

Author: Nico Martens

Blog: https://www.sharepointrelated.com
Twitter: @martensnico

Version 0.9

*********************************************#>

# Initialize steps here
$steps = @(
	(0,"Connect Azure Active Directory (AzureAD)",1),
	(0,"Connect Microsoft Online (Msol)",2),
	(0,"Connect SharePoint Online (SPO)",3),
	(0,"Connect Exchange Online",4),
	(0,"Connect Skype for Business Online",5),
	(0,"Connect Microsoft Teams",6),
	(0,"Connect Security & Compliance",7),
	(0,"Connect PNP",8),
	(0,"--> Connect All <--",9))



function RunSteps ($steps)
{
	Clear-Host
	printlogo

	if ($steps[0][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-AAD}
	if ($steps[1][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-MSOL}
	if ($steps[2][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-SPO}
	if ($steps[3][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-EXO}
	if ($steps[4][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-S4B}
	if ($steps[5][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-MSTeams}
	if ($steps[6][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-SandC}
	if ($steps[7][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-PNP}
}

function WaitAnyKey ()
{
	$HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
	$HOST.UI.RawUI.Flushinputbuffer()
}

function printlogo ()
{
	Write-Output ("_________                                     __    ________   _____  _____.__             ________   ________.________")
	Write-Output ("\_   ___ \  ____   ____   ____   ____   _____/  |_  \_____  \_/ ____\/ ____\__| ____  ____ \_____  \ /  _____/|   ____/")
	Write-Output ("/    \  \/ /  _ \ /    \ /    \_/ __ \_/ ___\   __\  /   |   \   __\\   __\|  |/ ___\/ __ \  _(__  </   __  \ |____  \ ")
	Write-Output ("\     \___(  <_> )   |  \   |  \  ___/\  \___|  |   /    |    \  |   |  |  |  \  \__\  ___/ /       \  |__\  \/       \")
	Write-Output ("\______  /\____/|___|  /___|  /\___  >\___  >__|   \_______  /__|   |__|  |__|\___  >___  >______  /\_____  /______  /")
	Write-Output ("       \/            \/     \/     \/     \/               \/                     \/    \/       \/       \/       \/ ")
}

function ResetSteps ($steps)
{
	foreach ($step in $steps) {
		$step[0] = 0
	}
}

function GetCheckedValue ([int]$value)
{
	if ($value -eq 0) { return " " } else { return "x" }
}

function SetStep ($selection,$steps)
{

	$val = [convert]::ToInt32([convert]::ToString($selection)) - 1
	if ($steps[$val][0] -eq 0)
	{
		$steps[$val][0] = 1
	}
	else
	{
		$steps[$val][0] = 0
	}
}

function ShowMenu ($steps)
{
	Clear-Host
	printlogo
	$i = 1
	foreach ($step in $steps) {
		Write-Output ("[{0}] {1}. {2}" -f (GetCheckedValue $step[0]),$i,$step[1])
		$i++
	}
}

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
}

function Connect-Office365 ()
{
<#
.SYNOPSIS
Connect to Office 365 PowerShell using credentials stored in Credential Manager (Windows Generic Credentials).
.DESCRIPTION
The Connect-Office365 cmdlet provides a secure way to connect to any Office 365 tenant
by using PowerShell. Select which services you want to connect to and hit enter.
MFA is partially supported.

Note: Please use your tenant name as your credential name (for instance: "contoso").
The credential name is used to connect to SharePoint, in this case: https://contoso-admin.sharepoint.com
.EXAMPLE
Connect-Office365 -Tenant "Contoso"
Connects to tenant Contoso which uses no MFA.
The credential manager is checked for Windows Generic credentials with the name "Contoso".
It uses these credentials to connect to Office 365.
.EXAMPLE
Connect-Office365 -Tenant "Fabrikam" -MFA
Connects to tenant "Fabrikam" which uses MFA. You will be prompted for credentials
.PARAMETER Tenant
The value for this parameter is used to check the Windows Generic Credential Manager.
Please use your Office 365 tenant name (xxx.sharepoint.com) in the Internet or network address. 
.PARAMETER MFA
Should be used if MFA is enabled for your account.
When you use this switch parameter, you will be prompted for credentials when logging in to a service.
#>
	param(
		[Parameter(Mandatory = $true)]
		[string]$Tenant,
		[Parameter(Mandatory = $false)]
		[switch]$MFA
	)

	Clear-Host
	Get-Prerequisite
	$credential = Get-ManagedCredential $Tenant
	#Need to do this because of "feature" explained here: https://github.com/Azure/azure-docs-powershell-azuread/issues/169
	$Credential.password.MakeReadOnly()
	$continue = $true

	while ($continue) {

		ShowMenu $steps

		Write-Host ("")
		Write-Host ("Select option (q to quit, c to clear selections, Enter to run.):")
		Write-Host ("`nUsing account: $($credential.UserName)") -Fore "Yellow"
		$userInput = [System.Console]::ReadKey()

		switch ($userInput.key)
		{
			q { $continue = $false }
			c { ResetSteps ($steps) }
			Enter { RunSteps ($steps) }
			default { SetStep $userInput.keyChar $steps }
		}
	}
}

function Connect-AAD
{
	Write-Host $($credential.UserName)
	if ($MFA)
	{
		Write-Host ("Connecting Azure Active Directory with MFA") -Fore Yellow
		try {
			Connect-AzureAD -AccountID $credential.userName | Out-Null
			Write-Host ("Successfully connected to Azure Active Directory with MFA") -Fore Green
		}
		catch { Write-Host ("Could not connect to Azure Active Directory with MFA") }
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
		Import-PSSession $exchangeSession | Out-Null
		Write-Host ("Successfully connected to Exchange online") -Fore Green
	}
	catch { Write-Host ("Could not connect to Exchange Online with MFA") -Fore Red }
	}
}

function Connect-S4B
{
	if ($MFA)
	{
	Write-Host ("Connecting Skype for Business Online with MFA") -Fore Yellow
	try {
		$sfboSession = New-CsOnlineSession -UserName $credential.UserName
		Import-PSSession $sfboSession | Out-Null
		Write-Host ("Successfully connected to Skype for Business Online with MFA") -Fore Green
	}
	catch { Write-Host ("Could not connect to Skype for Business Online with MFA") -Fore Red }
	
	}
	if (!$MFA)
	{
	Write-Host ("Connecting Skype for Business Online") -Fore Yellow
	try {
		$sfboSession = New-CsOnlineSession -Credential $credential
		Import-PSSession $sfboSession | Out-Null
		Write-Host ("Successfully connected to Skype for Business Online") -Fore Green
	}
	catch { Write-Host ("Could not connect to Skype for Business Online") -Fore Red }
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

function Get-Prerequisite
{
	$modules = "CredentialManager","AzureAD","MicrosoftTeams","MSOnline","SharePointPnPPowerShellOnline","Microsoft.Online.SharePoint.PowerShell","SkypeOnlineConnector"
	$missingmodules = @()
	[boolean]$state = 1

	#Check modules
	foreach ($module in $modules)
	{
		if (Get-Module -ListAvailable -Name $module)
		{
			Write-Host ("Module $module found") -Fore Green
		}
		else
		{
			Write-Host ("Module $module missing") -Fore Red
			$missingmodules += $module
		}
	}

	#Microsoft Online Services Sign-in Assistant for IT Professionals RTW
	if ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") | Where-Object { $_.GetValue("DisplayName") -like "Microsoft Online Services Sign-in Assistant" })
	{
		Write-Host ("Microsoft Online Services Sign-in Assistant for IT Professionals RTW found") -Fore Green
	}
	else
	{
		Write-Host ("Microsoft Online Services Sign-in Assistant for IT Professionals RTW missing, please download here:") -Fore Red
		Write-Host ("https://www.microsoft.com/en-us/download/details.aspx?id=28177") -Fore Yellow
		$state = 0
	}

	#If services is missing and modules
	if ($state -eq 0 -and $missingmodules.count -eq 0)
	{
		Write-Host ("")
		Write-Host ("") -Fore red
		WaitAnyKey
		exit
	}
	elseif ($missingmodules.count -ge 1)
	{
		$title = "Install missing modules?"
		$message = "Do you want to install missing modules now?"
		$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
		$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
		$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
		$choice = $host.UI.PromptForChoice($title,$message,$options,1)

		if ($choice -eq 0)
		{
			if ([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))
			{
				Write-Host ("Current instance is running as administrator") -Fore Green

				foreach ($module in $missingmodules)
				{
					Write-Host ("Installing module $module") -Fore Yellow
					Install-Module $module
				}
			}
			else {
				Write-Host ("Please start PowerShell as administrator to install modules") -Fore Red
				WaitAnyKey
				exit
			}
		}
		Clear-Host
		Get-Prerequisite
	}
	Clear-Host
}