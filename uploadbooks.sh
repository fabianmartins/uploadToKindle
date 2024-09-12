#!/bin/bash

# ===========================================================================
# Script Name:  uploadbooks.sh
# Description:  Sends EPUB files from a specified folder to a Kindle email
#               address via Gmail using SMTP.
# Author:       Fabian Martins Da Silva
# Date Created: 2023-09-11
# Requirements:
#   - Bash (usually pre-installed on Linux)
#   - `ssmtp` or `msmtp` installed (for sending emails via SMTP)
#   - Gmail account with App Password enabled
#   - EPUB files located in the specified folder
# ===========================================================================

# Check if ssmtp or msmtp is installed
if ! command -v ssmtp &> /dev/null && ! command -v msmtp &> /dev/null; then
    echo "Error: Either 'ssmtp' or 'msmtp' needs to be installed to send emails."
    exit 1
fi

# Get username and app password from command-line arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <app_password>"
    exit 1
fi

username="$1"
app_password="$2"

# Avoid having your account locked
delay_seconds=30

# Configuration
recipient_email="<put here your @kindle.com>"
books_folder_path="Downloads/books" 
smtp_server="smtp.gmail.com"
smtp_port=587
sender_email="$username"
subject="EPUB File"
body="Please find the attached EPUB file."

# Get the full path to the books folder
folder_path="$HOME/$books_folder_path"

# Get all EPUB files in the folder
epub_files=("$folder_path"/*.epub)

# Loop through each EPUB file and send it via email
for epub_file in "${epub_files[@]}"; do

    # Construct the email with attachment using 'ssmtp' or 'msmtp'
    (
        echo "To: $recipient_email"
        echo "From: $sender_email"
        echo "Subject: $subject"
        echo "" # Empty line to separate headers from body
        echo "$body"
        echo "" # Empty line before attachment
        cat "$epub_file"
    ) | 
    if command -v ssmtp &> /dev/null; then
        ssmtp -au "$username" -ap "$app_password" -t
    else
        msmtp -a "$username" -p "$app_password" --tls-starttls --tls-certcheck=off -t
    fi

    if [ $? -eq 0 ]; then
        echo "Email with $(basename "$epub_file") sent successfully!"
    else
        echo "Error sending email with $(basename "$epub_file")"
    fi

    sleep $delay_seconds
done
