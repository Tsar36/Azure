Connect-AzureAD

# User data
$Email = "dmitry.oleksich@cpcs.ws"
$DisplayName = "Dmitry Oleksich"
$FirstName = "Dmitry"
$LastName = "Oleksich"
$JobTitle = "Data Analyst"
$RedirectUrl = "https://myapps.microsoft.com"


# Sending an invitation
$invitation = New-AzureADMSInvitation `
  -InvitedUserEmailAddress $Email `
  -InviteRedirectUrl $RedirectUrl `
  -SendInvitationMessage $true `
  -InvitedUserDisplayName $DisplayName `
  -InvitedUserType "Guest"

if ($invitation.InvitedUser.Id) {
    Set-AzureADUser `
        -ObjectId $invitation.InvitedUser.Id `
        -GivenName $FirstName `
        -Surname $LastName `
        -JobTitle $JobTitle

    Write-Host "✅ Invitation sent and user updated: $DisplayName <$Email>"
} else {
    Write-Warning "❌ Invitation could not be sent to $Email"
}