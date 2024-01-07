#!/bin/sh

## Created by: https://github.com/rojosnow
#
# Based on: David Nahodyl, Blue Feather, contact@bluefeathergroup.com
#   https://github.com/gearbox-solutions/FileMaker-LetsEncrypt-Mac/blob/master/GetSSL.sh

function usage() {
    cat <<USAGE
    Renews an SSL Certificate from the Let's Encrypt Certificate Authority (CA)
    to encypt data in motion for FileMaker. Uses the certbot deploy hook only 
    if the SSL Certificate is successfully renewed. Renewals happen within 
    30 days of expiration.

    This script renews a single domain and is designed to work with crontab.
    
    Must be run as root.

    Options:
        --deploy-hook       Set the full path to the certbot deploy hook
        -h, --help          Print this help message.

    Depoly Hook Path:
    --deploy-hook
        Enter the path to the certbot deploy hook 
            Default: "/etc/letsencrypt/fms-deploy-hook.sh"

USAGE
    exit 1
}

# set default deploy hook location
DEPLOY_HOOK="/etc/letsencrypt/fms-deploy-hook.sh"

# Set flags
echo
while [ "$1" != "" ]; do
	case $1 in

	--deploy-hook)
		shift
		DEPLOY_HOOK=$1
		;;

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

# Checks to see if script is running as root.
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Check to see if certbot is installed.
if ! type certbot > /dev/null; then
    printf "\033[1;31mError: Certbot could not be found\033[0m\n"
    echo "Install Certbot https://certbot.eff.org"
    exit 1
fi

# Make sure there is a non-empty file
if [[ -s $DEPLOY_HOOK ]]; then
    # Try to eenew the certificate
    certbot renew --deploy-hook "${DEPLOY_HOOK}" -q
else
    printf "\033[1;31mError: Missing or empty deploy hook file: $DEPLOY_HOOK\033[0m\n" && exit 1
fi

exit 0
