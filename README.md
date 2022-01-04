# FileMaker-LetsEncrypt-Mac
A bash script for fetching and renewing Let's Encrypt SSL certificates for FileMaker Server running on Mac.

Setup instructions and an example video can be found at https://bluefeathergroup.com/blog/lets-encrypt-ssl-certificates-for-filemaker-server-for-mac/

## How to use:
The script utilizes certbot to get SSL certificates from Let's Encrypt. Install certbot via homebrew:
```
brew install certbot
```

Change directory into the cloned repository and run:
```
sudo ./GetSSL.sh
```
*Script requires root privileges for certain functions. Always review the code before running any script as root.*

For help on options, run:
```
./GetSSL.sh --help
```