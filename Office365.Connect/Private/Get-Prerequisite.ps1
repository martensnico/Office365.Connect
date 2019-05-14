function Get-Prerequisite
{
	$modules = "CredentialManager","MicrosoftTeams","MSOnline","SharePointPnPPowerShellOnline","Microsoft.Online.SharePoint.PowerShell"
	[System.Collections.ArrayList]$missingmodules = @()
	[System.Collections.ArrayList]$availablemodules = @()

		#Check modules
	foreach ($module in $modules)
	{	
		if (Get-Module -ListAvailable -Name $module)
		{
			$availablemodules += $module
		}
		else
		{
			$missingmodules += $module
		}
	}

	#Check Azure AD
	if(Get-Module -ListAvailable -Name "AzureAD")
	{
		$availablemodules += "AzureAD"
	}
	elseif(Get-Module -ListAvailable -Name "AzureADPreview"){
		$availablemodules += "AzureADPreview"
	}
	else {
		$missingmodules += "AzureAD"
	}
if($availablemodules.count -ge 1)
{
		Write-Host "Found required components:" -Fore Green
		$availablemodules | ForEach-Object{ Write-Host - "$_" -Fore Green}
}
if($missingmodules.count -ge 1)
{
		Write-Host ""
		Write-Host "Missing components:" -Fore Yellow
		$missingmodules | ForEach-Object{ Write-Host - "$_" -Fore Yellow}
}
	#If services is missing and modules
	if ($missingmodules.count -ge 1)
	{
		$title = "Install missing modules?"
		$message = "Do you want to install missing modules now?"
		$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
		$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
		$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
		$choice = $host.UI.PromptForChoice($title,$message,$options,1)

		if ($choice -eq 0)
		{
			if (Get-CurrentPrivilege -eq $true)
			{
				$i = 1
				$activity = "Downloading modules"

				foreach ($module in $missingmodules)
				{
						Write-Progress -Activity $activity -Status "Downloading module $($i.ToString().PadLeft($missingmodules.Count.ToString().Length)) of $($missingmodules.Count)" -CurrentOperation "Downloading module $($module)" -PercentComplete ($i / $missingmodules.count * 100)
						Install-Component $module
						$i++				
				}	
				Write-Progress -Activity $activity -Status "Ready" -Completed			
			}	
			else {
				Write-Host ("Please start PowerShell as administrator to install/update modules") -Fore Red;
				Write-Host ("The console will now exit so you can start it as an administrator") -Fore Red;
				WaitAnyKey; 
				exit
			}
		}
		Clear-Host
		Get-Prerequisite
	}
	Clear-Host
	
}

function Get-CurrentPrivilege
{
	$privilege = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
	return $privilege
}

function Install-Component($module)
{
	switch($module)
	{
		"Microsoft Online Services Sign-in Assistant for IT Professionals RTW"{Get-SigninAssistant}
		default{
			#Write-Host "Installing module $module" -Fore Yellow
			Install-Module $module -Force
			#Write-Host "Installed module $module" -Fore Green
		}
	}
}