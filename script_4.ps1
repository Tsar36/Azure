# Invite the users with personal invitation text message

Connect-AzureAD

# User data
$Email = "serhii@domain.com"
$DisplayName = "Serhii"
$FirstName = "Serhii"
$LastName = "User"
# $CompanyName = "NAME" The Set-AzureADUser command does not support the "-CompanyName" parameter.
$RedirectUrl = "https://myapps.microsoft.com"

# Invitation message
$InvitationMessage = Read-Host "Enter a text message for users... (Invitation message)"

# Message info object
$MessageInfo = @{
    CustomizedMessageBody = $InvitationMessage
}

# Sending an invitation
$invitation = New-AzureADMSInvitation `
  -InvitedUserEmailAddress $Email `
  -InviteRedirectUrl $RedirectUrl `
  -SendInvitationMessage $true `
  -InvitedUserDisplayName $DisplayName `
  -InvitedUserType "Guest" `
  -InvitedUserMessageInfo $MessageInfo

if ($invitation.InvitedUser.Id) {
    Set-AzureADUser `
        -ObjectId $invitation.InvitedUser.Id `
        -GivenName $FirstName `
        -Surname $LastName `
        -CompanyName $CompanyName  # Setting up a company name

    Write-Host "✅ Invitation sent and user updated: $DisplayName <$Email>"
} else {
    Write-Warning "❌ Invitation could not be sent to $Email"
}
