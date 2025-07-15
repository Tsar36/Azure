# GUI script for sending mass invitations:
# The script will send an invitation message to the AZ Portal to all the users from the "file_users.csv"

Add-Type -AssemblyName System.Windows.Forms

# Creating a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Sending Bulk Invites"
$form.Size = New-Object System.Drawing.Size(500, 300)
$form.StartPosition = "CenterScreen"

# Label and message input field
$labelMessage = New-Object System.Windows.Forms.Label
$labelMessage.Text = "Enter a general invitation (it will be the same for everyone):"
$labelMessage.Top = 10
$labelMessage.Left = 10
$labelMessage.Width = 460
$form.Controls.Add($labelMessage)

$textBoxMessage = New-Object System.Windows.Forms.TextBox
$textBoxMessage.Top = 35
$textBoxMessage.Left = 10
$textBoxMessage.Width = 460
$textBoxMessage.Height = 60
$textBoxMessage.Multiline = $true
$form.Controls.Add($textBoxMessage)

# Button to select CSV file
$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "Select CSV file"
$btnBrowse.Top = 110
$btnBrowse.Left = 10
$btnBrowse.Width = 200
$form.Controls.Add($btnBrowse)

# Selected path label
$labelFile = New-Object System.Windows.Forms.Label
$labelFile.Text = "File not selected."
$labelFile.Top = 145
$labelFile.Left = 10
$labelFile.Width = 460
$form.Controls.Add($labelFile)

# Start button
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Send invitations"
$btnRun.Top = 180
$btnRun.Left = 10
$btnRun.Width = 460
$form.Controls.Add($btnRun)

# Global variable for path
$global:csvPath = ""

# File selection action
$btnBrowse.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "CSV Files (*.csv)|*.csv"
    if ($fileDialog.ShowDialog() -eq "OK") {
        $global:csvPath = $fileDialog.FileName
        $labelFile.Text = "Выбран файл: $($csvPath)"
    }
})

# Send Invites Action
$btnRun.Add_Click({
    if (-not (Test-Path $csvPath)) {
        [System.Windows.Forms.MessageBox]::Show("❌ CSV-file not selected or not found.", "Error")
        return
    }

    Connect-AzureAD

    $InvitationMessage = $textBoxMessage.Text
    $users = Import-Csv -Path $csvPath

    foreach ($user in $users) {
        $Email = $user.Email
        $DisplayName = $user.DisplayName
        $FirstName = $user.FirstName
        $LastName = $user.LastName
        $CompanyName = $user.CompanyName
        $RedirectUrl = "https://myapps.microsoft.com"

        $MessageInfo = @{
            CustomizedMessageBody = $InvitationMessage
        }

        try {
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
                    -CompanyName $CompanyName

                Write-Host "✅ Sent: $DisplayName <$Email>"
            } else {
                Write-Warning "❌ Failed to send invitation to $Email"
            }
        } catch {
            Write-Warning "Error sending to $Email"
        }
    }

    [System.Windows.Forms.MessageBox]::Show("✅ Bulk sending completed.", "Done")
})

# Show the form
$form.ShowDialog()
