#!/bin/sh

# Created by: David Nahodyl, Blue Feather
# Contact: contact@bluefeathergroup.com
# Date: 2/1/2019
# Version: 0.3

# Need help? We can set this up to run on your server for you! Send an email to 
# contact@bluefeathergroup.com or give a call at (770) 765-6258

# Change the domain variable to the domain/subdomain for which you would like
# an SSL Certificate
DOMAIN="fms.mycompany.com"

# Change the contact email address to your real email address so that Let's Encrypt
# can contact you if there are any problems #>
EMAIL="myemail@mycompoany.com"

# Enter the path to your FileMaker Server directory, ending in a slash 
SERVER_PATH="/Library/FileMaker Server/"

#
# --- you shouldn't need to edit anything below this line
#

WEB_ROOT="${SERVER_PATH}HTTPServer/htdocs"


# Get the certificate
certbot certonly --webroot -w "$WEB_ROOT" -d $DOMAIN --agree-tos -m "$EMAIL" --preferred-challenges "http" -n

cp "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" "${SERVER_PATH}CStore/fullchain.pem"
cp "/etc/letsencrypt/live/${DOMAIN}/privkey.pem" "${SERVER_PATH}CStore/privkey.pem"

chmod 640 "${SERVER_PATH}CStore/privkey.pem"

# Move an old certificate, if there is one, to prevent an error
mv "${SERVER_PATH}CStore/serverKey.pem" "${SERVER_PATH}CStore/serverKey-old.pem"

# Install the certificate
fmsadmin certificate import "${SERVER_PATH}CStore/fullchain.pem" --keyfile "${SERVER_PATH}CStore/privkey.pem" -y

# Stop FileMaker Server
launchctl stop com.filemaker.fms

# Wait 15 seconds for it to stop
sleep 15s

# Start FileMaker Server again
launchctl start com.filemaker.fms
