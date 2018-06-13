function Get-Prerequisite
{
	$modules = "CredentialManager","MicrosoftTeams","MSOnline","SharePointPnPPowerShellOnline","Microsoft.Online.SharePoint.PowerShell"
	[System.Collections.ArrayList]$missingmodules = @()

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

	#Check Azure AD
	if(Get-Module -ListAvailable -Name "AzureAD")
	{
		Write-Host ("Module AzureAD found") -Fore Green
	}
	elseif(Get-Module -ListAvailable -Name "AzureADPreview"){
		Write-Host ("Module AzureADPreview found") -Fore Green
	}
	else {
		$missingmodules += "AzureAD"
	}

	#Check Skype for Business Module	
	if(Test-Path "$env:ProgramFiles\Common Files\Skype for business Online\Modules")
	{
		Write-Host "Module SkypeforBusiness found" -Fore Green
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
	$missingmodules.Remove("Signin")
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
	Invoke-WebRequest -Uri $URL -UseBasicParsing -OutFile $file

	Write-Host("Installing Skype for Business Online Powershell module") -Fore Yellow
	Set-Location $env:TEMP
	[string]$expression = ".\SkypeOnlinePowershell.exe /quiet /norestart /l* $env:TEMP\SkypeOnlinePowerShell.log"
	Invoke-Expression $expression
	Start-Sleep -Seconds 5
	Do{
$CheckForSfbO = Test-Path "$env:ProgramFiles\Common Files\Skype for business Online\Modules"
Start-Sleep -Seconds 5
$LoopError += 1
}
Until ($CheckForSfbO -eq $true -or $LoopError -eq 10)
	Write-Host("Skype for Business Online Powershell module has been installed") -Fore Green
	$missingmodules.Remove("SkypeOnlineConnector")
	}
}