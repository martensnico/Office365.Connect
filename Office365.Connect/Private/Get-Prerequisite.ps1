function Get-Prerequisite
{
	$modules = "CredentialManager","MicrosoftTeams","MSOnline","SharePointPnPPowerShellOnline"
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

	#SharePoint Online Management Shell
	if ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") | Where-Object { $_.GetValue("DisplayName") -like "SharePoint Online Management Shell" })
	{
		$availablemodules += "SharePoint Online Management Shell"
	}
	else
	{
		$missingmodules += "SharePoint Online Management Shell"
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
				Write-Host "Please restart PowerShell and run Connect-Office365 again" -Fore Yellow
				WaitAnyKey
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
	if($privilege -eq $false){Write-Host ("Please start PowerShell as administrator to install modules") -Fore Red; WaitAnyKey; exit}
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
}

function Get-SPOPowerShell
{
	if(Get-CurrentPrivilege -eq $true)
	{
	Write-Host("Downloading SharePoint Online Management Shell") -Fore Yellow
	$URL = "https://download.microsoft.com/download/0/2/E/02E7E5BA-2190-44A8-B407-BC73CA0D6B87/SharePointOnlineManagementShell_7918-1200_x64_en-us.msi"
	        
	$Filename = $URL.Split('/')[-1]
	Invoke-WebRequest -Uri $URL -UseBasicParsing -OutFile "$env:TEMP\$Filename" 

	Write-Host("Installing SharePoint Online Management Shell") -Fore Yellow
	& $env:TEMP\$Filename /qn
	Write-Host("SharePoint Online Management Shell has been installed") -Fore Green
	Start-Sleep -Seconds 3
	}
}

function Install-Component($module)
{
	switch($module)
	{
		"Microsoft Online Services Sign-in Assistant for IT Professionals RTW"{Get-SigninAssistant}
		"SharePoint Online Management Shell"{Get-SPOPowerShell}
		default{
			Write-Host "Installing module $module" -Fore Yellow
			Install-Module $module -Force
			Write-Host "Installed module $module" -Fore Green
		}
	}
}