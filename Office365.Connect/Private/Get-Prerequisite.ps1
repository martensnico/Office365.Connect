
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