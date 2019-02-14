function InitializeSteps
{
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

	return $steps
}

function RunSteps ($steps)
{
	[System.Collections.ArrayList]$stepstrue = @()
	Clear-Host
	printlogo

	if ($steps[0][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-AAD; $stepstrue += $steps[0][1]}
	if ($steps[1][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-MSOL; $stepstrue += $steps[1][1]}
	if ($steps[2][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-SPO; $stepstrue += $steps[2][1]}
	if ($steps[3][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-EXO; $stepstrue += $steps[3][1]}
	if ($steps[4][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-S4B; $stepstrue += $steps[4][1]}
	if ($steps[5][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-MSTeams; $stepstrue += $steps[5][1]}
	if ($steps[6][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-SandC; $stepstrue += $steps[6][1]}
	if ($steps[7][0] -eq 1 -or $steps[8][0] -eq 1) {Connect-PNP; $stepstrue += $steps[7][1]}
	
}

function WaitAnyKey
{
	$HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
	$HOST.UI.RawUI.Flushinputbuffer()
}

function printlogo
{
	Write-Output ("_________                                     __    ________   _____  _____.__             ________   ________.________")
	Write-Output ("\_   ___ \  ____   ____   ____   ____   _____/  |_  \_____  \_/ ____\/ ____\__| ____  ____ \_____  \ /  _____/|   ____/")
	Write-Output ("/    \  \/ /  _ \ /    \ /    \_/ __ \_/ ___\   __\  /   |   \   __\\   __\|  |/ ___\/ __ \  _(__  </   __  \ |____  \ ")
	Write-Output ("\     \___(  <_> )   |  \   |  \  ___/\  \___|  |   /    |    \  |   |  |  |  \  \__\  ___/ /       \  |__\  \/       \")
	Write-Output ("\______  /\____/|___|  /___|  /\___  >\___  >__|   \_______  /__|   |__|  |__|\___  >___  >______  /\_____  /______  /")
	Write-Output ("       \/            \/     \/     \/     \/               \/                     \/    \/       \/       \/       \/ ")
	Write-Output ("")
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