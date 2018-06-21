function Connect-Office365
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
    [cmdletbinding()]
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
	$steps = InitializeSteps

	while ($continue) {

		ShowMenu $steps

		Write-Host ("")
		Write-Host "If you are done connecting to the different services, hit `"q`"" -Fore 	Green
		Write-Host ("Select option (q to quit, c to clear selections, Enter to run.):")
		Write-Host ("")
		Write-Host ("Using account: $($credential.UserName)") -Fore "Yellow"
		$userInput = [System.Console]::ReadKey()

		switch ($userInput.key)
		{
			q { $continue = $false }
			c { ResetSteps ($steps) }
			Enter { RunSteps ($steps);$choice = checkContinue;if($choice -eq 0){$continue = $false} }
			default { SetStep $userInput.keyChar $steps }
		}
	}
}

function checkContinue{
	$title = "Connections done"
	$message = "Do you want to exit the menu and start working?"
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
	$choice = $host.UI.PromptForChoice($title,$message,$options,0)

	return $choice
	
}