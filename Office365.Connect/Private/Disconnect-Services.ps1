function Disconnect-AAD
{
    try{
        
        if(Get-AzureADDomain)
        Disconnect-AzureAD 
        Write-Host("Disconnected Azure Active Directory") -Fore Green
    }
    catch  {
        Write-Host "Azure Active Directory $($_.Exception.Message)" -Fore Yellow
    }
}

function Disconnect-SPO
{
    try{        
        Disconnect-SPOService
        Write-Host("SharePoint Online - Disconnected SharePoint Online") -Fore Green
    }
    catch{ 
        Write-Host "SharePoint Online - $($_.Exception.Message)" -Fore Yellow
     }
   
}

function Disconnect-EXO
{
    $exchangeSession =  Get-PSSession | Where-Object{$_.ComputerName -eq "outlook.office365.com"}
    if($exchangeSession){$exchangeSession | Remove-PSSession; Write-Host("Disconnected Exchange Online") -Fore Green}
    else{Write-Host("Exchange Online - No active Exchange Online sessions found") -Fore Yellow}
}

function Disconnect-S4B
{
    Get-PSSession | Where-Object{$_.ComputerName -like "*.online.lync.com"} | Remove-PSSession; Write-Host("Disconnected Skype for Business Online") -Fore Green
}

function Disconnect-MSTeams
{
    try{
        Disconnect-MicrosoftTeams
    }
    catch{
        Write-Host "Microsoft Teams - $($_.Exception.Message)" -Fore Yellow
    }
    
}

function Disconnect-SandC
{
    $sandcsession =  Get-PSSession | Where-Object{$_.ComputerName -like "*.compliance.protection.outlook.com"}
    if($sandcsession) { $sandcsession | Remove-PSSession; Write-Host("Disconnected Security & Compliance") -Fore Green}
    else{Write-Host("Security & Compliance - No active Security & Compliance sessions found")}
}

function Disconnect-PNP
{
    Disconnect-PnPOnline
}