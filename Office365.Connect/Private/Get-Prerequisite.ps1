function Get-Prerequisite
{
	$modules = "CredentialManager","AzureAD","MicrosoftTeams","MSOnline","SharePointPnPPowerShellOnline","Microsoft.Online.SharePoint.PowerShell"
	$missingmodules = @()

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

	#Check Skype for Business Module	
	if(Test-Path "$env:ProgramFiles\Common Files\Skype for business Online\Modules")
	{
		Write-Host "Module SkypeforBusiness found"
	}
	else{$missingmodules += "SkypeOnlineConnector"; Write-Host("Module SkypeOnlineConnector missing") -Fore Red}

	#Microsoft Online Services Sign-in Assistant for IT Professionals RTW
	if ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") | Where-Object { $_.GetValue("DisplayName") -like "Microsoft Online Services Sign-in Assistant" })
	{
		Write-Host ("Microsoft Online Services Sign-in Assistant for IT Professionals RTW found") -Fore Green
	}
	else
	{
		Write-Host ("Microsoft Online Services Sign-in Assistant for IT Professionals RTW missing") -Fore Red
		$missingmodules += "Signin"
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
				foreach ($module in $missingmodules)
				{
					if($module -eq "SkypeOnlineConnector")
						{
							Get-S4BModule
						}
						if($module -eq "Signin")
						{
							Get-SigninAssistant
						}
						else{
						Write-Host ("Installing module $module") -Fore Yellow
						Install-Module $module -Force
					}
						
				}
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
	if($privilege -eq $true){Write-Host ("Current instance is running as administrator") -Fore Green}
	else{Write-Host ("Please start PowerShell as administrator to install modules") -Fore Red; WaitAnyKey; exit}
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
	}
}

function Get-S4BModule
{
	if(Get-CurrentPrivilege -eq $true)
	{
	Write-Host("Downloading Skype for Business Online Powershell module") -Fore Yellow
	$URL = "https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowerShell.Exe"
	$Filename = $URL.Split('/')[-1]
	$file = "$env:TEMP\$Filename" 
	Write-Host $file
	Invoke-WebRequest -Uri $URL -UseBasicParsing -OutFile $file

	Write-Host("Installing Skype for Business Online Powershell module") -Fore Yellow

	. $file /S /v /qn
	Write-Host("Skype for Business Online Powershell module has been installed") -Fore Green
	Start-Sleep -Seconds 2
	}
}