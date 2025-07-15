$guests = Import-Csv "./guests.csv"

foreach ($guest in $guests) {
    $email = $guest.Email
    $displayName = $guest.DisplayName
    $firstName = $guest.FirstName
    $lastName = $guest.LastName
    # $jobTitle = $guest.JobTitle
    # $company = $guest.CompanyName

    Write-Host "We invite: $displayName <$email>"

    $invitation = az ad user invitation create `
        --user-principal-name $email `
        --invite-redirect-url "https://portal.azure.com" `
        --send-invitation-message true `
        --display-name "$displayName" `
        --query "{userId: invitedUser.id}" `
        | ConvertFrom-Json

    if ($invitation.userId) {
        az ad user update `
            --id $invitation.userId `
            --set givenName="$firstName" surname="$lastName" jobTitle="$jobTitle" companyName="$company"
        Write-Host "Invited: $email"
    } else {
        Write-Warning "Failed to invite: $email"
    }
}
