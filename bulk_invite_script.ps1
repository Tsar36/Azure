# Connecting to AzureAD
Connect-AzureAD

# Read the invitation message once
$InvitationMessage = Read-Host "Enter the invitation text for all users"
$MessageInfo = @{
    CustomizedMessageBody = $InvitationMessage
}

# Uploading a CSV file (should be in the same path in Azure CloudShell)
$csvPath = ".\users.csv"
$users = Import-Csv -Path $csvPath

# We sort through users
foreach ($user in $users) {
    Write-Host "Sending an invitation: $($user.DisplayName) <$($user.Email)>"

    try {
        $invitation = New-AzureADMSInvitation `
            -InvitedUserEmailAddress $user.Email `
            -InviteRedirectUrl "https://myapps.microsoft.com" `
            -SendInvitationMessage $true `
            -InvitedUserDisplayName $user.DisplayName `
            -InvitedUserType "Guest" `
            -InvitedUserMessageInfo $MessageInfo

        if ($invitation.InvitedUser.Id) {
            # Update user data (if available)
            Set-AzureADUser `
                -ObjectId $invitation.InvitedUser.Id `
                -GivenName $user.FirstName `
                -Surname $user.LastName

            # Set CompanyName using extension attribute
            Set-AzureADUserExtension `
                -ObjectId $invitation.InvitedUser.Id `
                -ExtensionName "extensionAttribute1" `
                -ExtensionValue $user.CompanyName

            Write-Host "Successfully submitted and updated: $($user.Email)"
        } else {
            Write-Warning "Failed to send: $($user.Email)"
        }

    } catch {
        Write-Warning "‼ Error while inviting $($user.Email): $_"
    }
}
