# connect to Azure
Connect-AzureAD

# Import CSV
$guests = Import-Csv "C:\path\to\guests.csv"

foreach ($guest in $guests) {
    New-AzureADMSInvitation `
        -InvitedUserEmailAddress $guest.Email `
        -InvitedUserDisplayName $guest.DisplayName `
        -InviteRedirectUrl "https://myapps.microsoft.com" `
        -SendInvitationMessage $true `
        -InvitedUserType "Guest"
}
