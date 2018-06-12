function Disconnect-AAD
{
    try{
        Disconnect-AzureAD -EA SilentlyContinue -ErrorVariable AADError
        Write-Host("Azure Active Directory - Disconnected") -Fore Green
    }
    catch  {
        if($AADError.Exception.Message -eq "Object reference not set to an instance of an object."){
        Write-Host "Azure AD - No active Azure Active Directory Connections" -Fore Yellow
        }
        else
        {
            Write-Host "Azure Active Directory - $($_.Exception.Message)" -Fore Yellow
        }
        
    }
}

function Disconnect-SPO
{
    try{        
        Disconnect-SPOService
        Write-Host("SharePoint Online - Disconnected") -Fore Green
    }
    catch{ 
        Write-Host "SharePoint Online - No active SharePoint Online sessions found" -Fore Yellow
     }
   
}

function Disconnect-EXO
{
    $exchangeSession =  Get-PSSession | Where-Object{$_.ComputerName -eq "outlook.office365.com"}
    if($exchangeSession){$exchangeSession | Remove-PSSession; Write-Host("Exchange Online - Disconnected") -Fore Green}
    else{Write-Host("Exchange Online - No active Exchange Online sessions found") -Fore Yellow}
}

function Disconnect-S4B
{
    $s4bSession =  Get-PSSession | Where-Object{$_.ComputerName -like "*.online.lync.com"} 
    if($s4bSession){$s4bSession | Remove-PSSession; Write-Host("Skype for Business - Disconnected") -Fore Green}
}

function Disconnect-MSTeams
{
    try{
        Disconnect-MicrosoftTeams -EA SilentlyContinue -ErrorVariable TeamsError
    }
    catch{
        if($TeamsError.Exception.Message -eq "Object reference not set to an instance of an object."){
        Write-Host "Microsoft Teams - No active Teams connections found" -Fore Yellow}
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