function Disconnect-Office365 ()
{
<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

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
if($AzureAD){Disconnect-AAD}
if($SharePoint){Disconnect-SPO}
if($Exchange){Disconnect-EXO}
if($Skype){Disconnect-S4B}
if($Teams){Disconnect-MSTeams}
if($Compliance){Disconnect-SandC}
if($PNP){Disconnect-PNP}
if($AzureAD -eq $false -and $SharePoint -eq $false -and $Exchange -eq $false -and $Skype -eq $false -and $Teams -eq $false -and $Compliance -eq $false -and $PNP -eq $false){Disconnect-AAD;Disconnect-SPO;Disconnect-EXO;Disconnect-S4B;Disconnect-MSTeams;Disconnect-SandC;Disconnect-PNP}
}