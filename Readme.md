This is a PowerShell Module designed for assisting being able to work with Office 365 tenants with just 1 cmdlet.

*NEW FEATURES in version 7.9*
- Update modules used by Office365.Connect by using "U" in the menu
- If you specify a new tenant name that doesn't exist, it creates the credentials for you! 


*Installation*
Install-Module Office365.Connect

*Use - No MFA*

Connect-Office365 -Tenant "Contoso"

*Use - MFA*

Connect-Office365 -Tenant "Fabrikam" -MFA

*Parameters*

- Tenant: Use the tenant name (xxx.sharepoint.com)
- MFA: Switch, if added, will prompt for MFA.
 
