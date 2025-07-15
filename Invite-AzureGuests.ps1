# =================== Configuration ===================
$tenantId = "35213a26-f94f-48eb-962f-7d79519b944f"
$clientId = "9848bc9d-4299-481c-bfa4-9a33c9a19b74"
$clientSecret = "eJC8Q~RakWdL1BpmjbN5eaT1wWAuYMcRD3T4pbT5"
$csvPath = "./users_to_invite.csv"

# =================== Secure the secret ===================
$secureClientSecret = ConvertTo-SecureString $clientSecret -AsPlainText -Force

# token
$tokenResponse = Get-MsalToken -ClientId $clientId `
                               -ClientSecret $secureClientSecret `
                               -TenantId $tenantId `
                               -Scopes "https://graph.microsoft.com/.default"

$token = $tokenResponse.AccessToken

# SecureString
$secureToken = ConvertTo-SecureString $token -AsPlainText -Force

# Connect to Microsoft Graph
Connect-MgGraph -AccessToken $secureToken


# =================== Custom invitation message ===================
$customMessage = @"
Hello,

You have been invited to join our Azure AD portal as a guest.

Please follow the link in the invitation email to access the system.

Best regards,  
DevOps Team
"@

# =================== Load users from CSV ===================
try {
    $users = Import-Csv -Path $csvPath
} catch {
    Write-Error "❌ Failed to load CSV: $_"
    exit 1
}

# =================== Invite users ===================
foreach ($user in $users) {
    try {
        Write-Host "Inviting: $($user.Email)..." -ForegroundColor Cyan

        $inviteParams = @{
            InvitedUserEmailAddress = $user.Email
            InvitedUserDisplayName  = $user.DisplayName
            InviteRedirectUrl       = "https://portal.azure.com"
            SendInvitationMessage   = $true
            InvitedUserMessageInfo  = @{
                CustomizedMessageBody = $customMessage
            }
        }

        New-MgInvitation @inviteParams

        Write-Host "✅ Invitation sent to: $($user.Email)" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Failed to invite $($user.Email): $_"
    }
}