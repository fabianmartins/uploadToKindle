# ===========================================================================
# Script Name:  Send-BooksToKindle.ps1
# Description:  Sends EPUB files from a specified folder to a Kindle email
#               address via Gmail using SMTP.
# Author:       Fabian Martins Da Silva
# Date Created: 2023-09-11 
# Requirements: 
#   - PowerShell 5.1 or higher
#   - Gmail account with App Password enabled
#   - EPUB files located in the specified folder
# ===========================================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$AppPassword
)

# Avoid having your account locked by inserting a delay between each email sent
$delaySeconds = 30 # seconds

$to = "<put here your @kindle.com>" # destination email
$booksFolderPath = "Downloads\books" # Adjust the folder path if needed
$smtpServer = "smtp.gmail.com" #adjust with the desired SMTP server
$smtpPort = 587
$from = $Username
$subject = "EPUB File"
$body = "Please find the attached EPUB file."

# Select the folder and files
$folderPath = Join-Path $env:USERPROFILE $booksFolderPath
$ePubFiles = Get-ChildItem $folderPath -Filter "*.epub"

# Create the SmtpClient and set its properties
$smtpClient = New-Object Net.Mail.SmtpClient($smtpServer, $smtpPort)
$smtpClient.EnableSsl = $true
$smtpClient.Credentials = New-Object System.Net.NetworkCredential($Username, $AppPassword)

foreach ($ePubFile in $ePubFiles) {
    $mailMessage = New-Object Net.Mail.MailMessage($from, $to, $subject, $body)
    $attachment = New-Object Net.Mail.Attachment($ePubFile.FullName)
    $mailMessage.Attachments.Add($attachment)
    try {
        $smtpClient.Send($mailMessage)
        Write-Host "Email with $($ePubFile.Name) sent successfully!" -ForegroundColor Green
        
        # Introduce a delay before sending the next email
        Start-Sleep -Seconds $delaySeconds
  
    }
    catch {
        Write-Host "Error sending email with $($ePubFile.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}
