#!/bin/sh

## Created by: https://github.com/rojosnow
# 
# Based on: David Nahodyl, Blue Feather, contact@bluefeathergroup.com
#   https://github.com/gearbox-solutions/FileMaker-LetsEncrypt-Mac/blob/master/GetSSL.sh

# Need for Deploy Hook:
# certbot renew exit status will only be 1 if a renewal attempt failed. This means 
# certbot renew exit status will be 0 if no certificate needs to be updated. If you 
# write a custom script and expect to run a command only after a certificate was 
# actually renewed you will need to use the --deploy-hook since the exit status will 
# be 0 both on successful renewal and when renewal is not necessary.
#   https://eff-certbot.readthedocs.io/en/stable/using.html#renewing-certificates

function usage() {
    cat <<USAGE
    WARNING! THIS SCRIPT WILL RESTART FILEMAKER SERVER!

    This certbot deploy hook runs after a successful renewal of an SSL Certificate 
    from the Let's Encrypt Certificate Authority (CA).

    This script renews a single domain.

    You will need to create a secure file containing four environment variables for
    this hook. A sample file has been included in the repo, `.fms_creds`
    As an example, you could place the file in the home of your user account with 
    `chmod 0640`, `chmod 0600`, or `chmod 0400` permission on the file. This will
    vary based upon your use case.
    
    This script uses the following env vars:
        export CERTBOT_DOMAIN="www.example.com"
        export FILEMAKER_SERVER_PATH="/Library/FileMaker Server/"
        export FILEMAKER_SERVER_ADMIN="YOUR_ADMIN_USERNAME"
        export FILEMAKER_SERVER_PWORD="YOUR_ADMIN_PASSWORD"

    Make sure you set the ENV_VAR_FULLPATH below to the file you've created above
    
    Must be run as root.

    Options:
	    -h, --help      Print this help message.

USAGE
    exit 1
}

# Set flags
echo
while [ "$1" != "" ]; do
	case $1 in

	-h | --help)
		usage
		exit 1
		;;

    	*)
		printf "\033[1;31mError: Invalid option!\033[0m\n"
		echo "Use --help for usage"
		exit 1
		;;
        
	esac
	shift
done


######################################
### SET YOUR ENV VAR FILE LOCATION ###
ENV_VAR_FULLPATH="/Users/admin/.fms_creds"
######################################

# Checks to see if script is running as root.
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Make sure there is a non-empty file
if [[ -s $ENV_VAR_FULLPATH ]]; then
    # source env vars
    . "$ENV_VAR_FULLPATH"

    # Get the certbot domain
    if [[ -z $CERTBOT_DOMAIN && -d "/etc/letsencrypt/live/${CERTBOT_DOMAIN}" ]]; then
        printf "\033[1;31mError: certbot domain is missing or not specified.\033[0m\n" && exit 1
    fi

    # Get the FMS path
    if [[ -z $FILEMAKER_SERVER_PATH && -d $FILEMAKER_SERVER_PATH ]]; then
        printf "\033[1;31mError: FileMaker Server Path is missing or not specified.\033[0m\n" && exit 1
    fi

    # Get values for fmsadmin, -u admin -p pword from env vars
    if [[ -z $FILEMAKER_SERVER_ADMIN || -z $FILEMAKER_SERVER_PWORD ]]; then
        printf "\033[1;31mError: FMS admin username and/or password not specified.\033[0m\n" && exit 1
    fi

else
    printf "\033[1;31mError: Missing or empty env vars file.\033[0m\n" && exit 1
fi

# Copy the keys into place
cp "/etc/letsencrypt/live/${CERTBOT_DOMAIN}/fullchain.pem" "${FILEMAKER_SERVER_PATH}CStore/fullchain.pem"
cp "/etc/letsencrypt/live/${CERTBOT_DOMAIN}/privkey.pem" "${FILEMAKER_SERVER_PATH}CStore/privkey.pem"

chmod 640 "${FILEMAKER_SERVER_PATH}CStore/privkey.pem"

# Move an old certificate, if there is one, to prevent an error
FILE=${FILEMAKER_SERVER_PATH}CStore/serverKey.pem
if test -f "$FILE"; then
    mv "${FILEMAKER_SERVER_PATH}CStore/serverKey.pem" "${FILEMAKER_SERVER_PATH}CStore/serverKey-old.pem"
fi

# Remove the old certificate
fmsadmin certificate delete -u "${FILEMAKER_SERVER_ADMIN}" -p "${FILEMAKER_SERVER_PWORD}" -y

# Install the certificate
fmsadmin certificate import "${FILEMAKER_SERVER_PATH}CStore/fullchain.pem" --keyfile "${FILEMAKER_SERVER_PATH}CStore/privkey.pem" -u "${FILEMAKER_SERVER_ADMIN}" -p "${FILEMAKER_SERVER_PWORD}" -y

# Stop FileMaker Server
launchctl stop com.filemaker.fms

# Wait 60 seconds for it to stop
sleep 60

# Start FileMaker Server again
launchctl start com.filemaker.fms

exit 0
