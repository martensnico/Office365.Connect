This is a PowerShell Module designed for assisting being able to work with Office 365 tenants with just 1 cmdlet.

Install

Install-Module Office365.Connect

Use
Connect-Office365 -Tenant "Contoso"         (no MFA)

Connect-Office365 -Tenant "Fabrikam" -MFA   (MFA enbabled)

Parameters
- Tenant: Use the tenant name (xxx.sharepoint.com)
- MFA: Switch, if added, will prompt for MFA.
