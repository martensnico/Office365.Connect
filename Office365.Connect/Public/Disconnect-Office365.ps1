function Disconnect-Office365 ()
{
<#
.SYNOPSIS
Disconnects Office 365 sessions. You can specify which service you want to disconnect. 

.DESCRIPTION
Disconnects Office 365 sessions. You can specify which service you want to disconnect. 
If you do not specify a specific service, all servies will be disconnected.

.EXAMPLE
Disconnect-Office365
Disconnects PowerShell for all services

.EXAMPLE
Disconnect-Office365 -Skype -Teams
Disconnects PowerShell for Skype for Business Online and Microsoft Teams
#>
[cmdletbinding()]
	param(
		[switch]$AzureAD,
		[switch]$SharePoint,
		[switch]$Exchange,
		[switch]$Skype,
		[switch]$Teams,
		[switch]$Compliance,
		[switch]$PNP
		)
$disconnectAll = $true
if($AzureAD){Disconnect-AAD; $disconnectAll = $false}
if($SharePoint){Disconnect-SPO; $disconnectAll = $false}
if($Exchange){Disconnect-EXO; $disconnectAll = $false}
if($Skype){Disconnect-S4B; $disconnectAll = $false}
if($Teams){Disconnect-MSTeams; $disconnectAll = $false}
if($Compliance){Disconnect-SandC; $disconnectAll = $false}
if($PNP){Disconnect-PNP; $disconnectAll = $false}
if($disconnectAll){Disconnect-AAD;Disconnect-SPO;Disconnect-EXO;Disconnect-S4B;Disconnect-MSTeams;Disconnect-SandC;Disconnect-PNP}
}
