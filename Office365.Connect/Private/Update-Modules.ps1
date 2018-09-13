
function Get-ModuleUpdate {
    cls
    Write-Host "Starting the Update Module process.." -ForegroundColor Green
    $modules = Get-Module -ListAvailable -Name "CredentialManager", "MicrosoftTeams", "MSOnline", "SharePointPnPPowerShellOnline"

    #Get duplicate modules
    $duplicates = ($modules | Group-Object name -NoElement | Where-Object count -gt 1).Name
    if($duplicates.count -ge 1)
    {

    #Go through all duplicates
    foreach($duplicate in $duplicates)
    {
    #Remove old versions         
        $duplicatemodules = Get-InstalledModule $duplicate -AllVersions

        foreach($duplicatemodule in $duplicatemodules)
        {
        $latest = get-installedmodule $duplicatemodule.Name
        if($duplicatemodule.version -ne $latest.version)
        {           
            Write-Host "Uninstalling module $($duplicatemodule.Name) with version $($duplicatemodule.version)"
            Uninstall-Module $duplicatemodule -force
        }
    }
    }
}
else {
    Write-Host "No duplicate modules found" -ForegroundColor Green
}
    #declare array
    $myarray = @()
    $modules = Get-Module -ListAvailable -Name "CredentialManager", "MicrosoftTeams", "MSOnline", "SharePointPnPPowerShellOnline"
    Write-Host "Comparing modules to online versions, this can take a minute" -ForegroundColor Yellow
    foreach ($module in $modules) {
        Write-Host "." -NoNewline
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
    }

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
        foreach ($module in $needupdatemodules) {
            Write-Host Updating module $module."Module Name"
            Update-Module $module."Module Name" -Force
        }
    }
    else {
            Write-Host ("Please start PowerShell as administrator to install/update modules") -Fore Red;
            Write-Host ("The console will now exit so you can start it as an administrator") -Fore Red; 
            WaitAnyKey; exit 
        }
}