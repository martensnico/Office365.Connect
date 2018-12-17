function Get-Prerequisite
{
	$modules = "CredentialManager","MicrosoftTeams","MSOnline","SharePointPnPPowerShellOnline","Microsoft.Online.SharePoint.PowerShell"
	[System.Collections.ArrayList]$missingmodules = @()
	[System.Collections.ArrayList]$availablemodules = @()
	#Microsoft Online Services Sign-in Assistant for IT Professionals RTW
	if ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") | Where-Object { $_.GetValue("DisplayName") -like "Microsoft Online Services Sign-in Assistant" })
	{
		$availablemodules += "Microsoft Online Services Sign-in Assistant for IT Professionals RTW"
	}
	else
	{
		$missingmodules += "Microsoft Online Services Sign-in Assistant for IT Professionals RTW"
	}

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

		Write-Host "Found required components:" -Fore Green
		$availablemodules | ForEach-Object{ Write-Host - "$_" -Fore Green}
		Write-Host ""
		Write-Host "Missing components:" -Fore Yellow
		$missingmodules | ForEach-Object{ Write-Host - "$_" -Fore Yellow}

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
				foreach ($module in $missingmodules)
				{
						Install-Component $module				
				}
				Write-Host ""
				Write-Host "We had to install some modules that require PowerShell to restart." -Fore Yellow
				
				do{$value = read-host "Press `"Y`" to exit the console"}
				while($value -ne "Y")
				exit
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

function Get-SigninAssistant
{
	if(Get-CurrentPrivilege -eq $true)
	{
	Write-Host("Downloading Microsoft Online Services Sign-in Assistant for IT Professionals RTW") -Fore Yellow
	$URL = "https://download.microsoft.com/download/7/1/E/71EF1D05-A42C-4A1F-8162-96494B5E615C/msoidcli_64bit.msi"
	$Filename = $URL.Split('/')[-1]
	Invoke-WebRequest -Uri $URL -UseBasicParsing -OutFile "$env:TEMP\$Filename" 

	Write-Host("Installing Microsoft Online Services Sign-in Assistant for IT Professionals RTW") -Fore Yellow
	& $env:TEMP\$Filename /qn
	Write-Host("Microsoft Online Services Sign-in Assistant for IT Professionals RTW has been installed") -Fore Green
	Start-Sleep -Seconds 3
	}
	else {
		Write-Host ("Please start PowerShell as administrator to install/update modules") -Fore Red
		Write-Host ("The console will now exit so you can start it as an administrator") -Fore Red
		WaitAnyKey
		exit
	}
}

function Install-Component($module)
{
	switch($module)
	{
		"Microsoft Online Services Sign-in Assistant for IT Professionals RTW"{Get-SigninAssistant}
		default{
			Write-Host "Installing module $module" -Fore Yellow
			Install-Module $module -Force
			Write-Host "Installed module $module" -Fore Green
		}
	}
}