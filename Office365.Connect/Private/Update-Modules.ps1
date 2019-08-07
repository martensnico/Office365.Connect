
function Get-ModuleUpdate {
    cls
    Write-Host "Starting the Update Module process.." -ForegroundColor Green
    $modules = Get-Module -ListAvailable -Name "CredentialManager", "MicrosoftTeams", "MSOnline", "SharePointPnPPowerShellOnline","Microsoft.Online.SharePoint.PowerShell"

    #declare array
    $myarray = @()
    $modules = Get-Module -ListAvailable -Name "CredentialManager", "MicrosoftTeams", "MSOnline", "SharePointPnPPowerShellOnline","Microsoft.Online.SharePoint.PowerShell"
    Write-Host "Comparing modules to online versions, this can take a minute" -ForegroundColor Yellow
   
    $i = 1
    $activity = "Checking modules against PowerShell Gallery"

    foreach ($module in $modules) {
        
        Write-Progress -Activity $activity -Status "Checking module $($i.ToString().PadLeft($modules.Count.ToString().Length)) of $($modules.Count)" -CurrentOperation "Checking module $($module)" -PercentComplete ($i / $modules.count * 100)
        #find the current version in the gallery
        Try {
            $online = Find-Module -Name $module.name -Repository PSGallery -ErrorAction Stop
        }
        Catch {
            Write-Warning "Module $($module.name) was not found in the PSGallery"
        }

        #compare versions
        if ($online.version -gt $module.version) {
            $UpdateAvailable = $True
        }
        else {
            $UpdateAvailable = $False
        }

        $myobj = New-Object -TypeName PSObject
        Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Module name' -Value $module.Name
        Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Current version' -Value $module.Version
        Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Latest version' -Value $online.Version  
        Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Update Available' -Value $UpdateAvailable
        $myarray += $myobj
        Clear-Variable myobj
        $i++
    }
    Write-Progress -Activity $activity -Status "Ready" -Completed	
    #all modules
    $myarray | Sort-Object Name | Format-Table *

    #filter modules to only have modules that need updating
    $needupdatemodules = $myarray | Where-Object {$_."Update Available" -eq $true}

if(($needupdatemodules).Count -ge 1)
{
    $title = "Update modules?"
    $message = "Do you want to update modules now?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $choice = $host.UI.PromptForChoice($title, $message, $options, 1)

    if ($choice -eq 0) {
        Update-Modules
    }
}
else
{
    Write-Host "All modules are up-to-date, press any key to return to the menu" -ForegroundColor Green
    WaitAnyKey
}

}

function Update-Modules {
    if (Get-CurrentPrivilege -eq $true) {
        
        $i = 1
        $activity = "Downloading modules from PowerShell Gallery"

        foreach ($module in $needupdatemodules) {
            Write-Progress -Activity $activity -Status "Downloading module $($i.ToString().PadLeft($needupdatemodules.Count.ToString().Length)) of $($needupdatemodules.Count)" -CurrentOperation "Downloading module $($module)" -PercentComplete ($i / $needupdatemodules.count * 100)
            Update-Module $module."Module Name" -Force
            $i++
        }
        Write-Progress -Activity $activity -Status "Ready" -Completed	
    }
    else {
            Write-Host ("Please start PowerShell as administrator to install/update modules") -Fore Red;
            Write-Host ("The console will now exit so you can start it as an administrator") -Fore Red; 
            WaitAnyKey; exit 
        }
}

function Get-DuplicateModules
{
cls
Write-Host "Starting the Remove duplicate Module process.." -ForegroundColor Green
$mods = Get-Module -ListAvailable -Name "CredentialManager", "MicrosoftTeams", "MSOnline", "SharePointPnPPowerShellOnline","Microsoft.Online.SharePoint.PowerShell"
 
$i = 1
$activity = "Checking duplicate modules"

foreach ($Mod in $mods)
{
    
  Write-Progress -Activity $activity -Status "Checking module $i of $($mods.Count)" -CurrentOperation "Checking module $($mod.Name)" -PercentComplete ($i / $mods.count * 100)
  $latest = get-installedmodule $mod.Name
  $specificmods = get-installedmodule $mod.Name -allversions
  
  foreach ($sm in $specificmods)
  {
    if ($sm.version -ne $latest.version)
	{
	  $sm | uninstall-module -force
	}
	
  }
  $i++
}
Write-Progress -Activity $activity -Status "Ready" -Completed
}