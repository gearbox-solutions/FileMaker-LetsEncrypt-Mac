# FileMaker-LetsEncrypt-Mac
A bash script for creating and renewing Let's Encrypt SSL certificates for FileMaker Server running on Mac.

## Installation Instructions

### Install certbot:
The script utilizes certbot to get SSL certificates from Let's Encrypt.

Install certbot via [homebrew](https://docs.brew.sh/Installation):
```
brew install certbot
```

### Clone the Repo
```
git clone <YOUR_PREFERRED_METHOD>
```

### Create SSL Install
Changed to the cloned directory. The following examples are for illustration only. Your needs may vary so make the necessary modifications for your environment.

Copy the `GetSSL.sh` file to an Application location on your Mac. Example: 
```
mkdir -p /Users/admin/Applications/cerbot
cp GetSSL.sh /Users/admin/Applications/cerbot/
# Set the permissions based upon your need, must be executable
chmod 0750 /Users/admin/Applications/cerbot/GetSSL.sh
```

### Renew SSL Install
Changed to the cloned directory. The following examples are for illustration only. Your needs may vary so make the necessary modifications for your environment.

**Step 1**

Copy the `RenewSSL.sh` file to an Application location on your Mac. Example: 
```
mkdir -p /Users/admin/Applications/cerbot
cp RenewSSL.sh /Users/admin/Applications/cerbot/
# Set the permissions based upon your need, must be executable
chmod 0750 /Users/admin/Applications/cerbot/RenewSSL.sh
```

**Step 2**

Copy the `.fms_creds` file to your user home. Example: 
```
cp .fms_creds ~
# Set the permissions based upon your need
chmod 0640 ~/.fms_creds
nano ~/.fms_creds
```

Fill in the values for:
```
export CERTBOT_DOMAIN="YOUR_DOMAIN"
export FILEMAKER_SERVER_PATH="/Library/FileMaker Server/"
export FILEMAKER_SERVER_ADMIN="YOUR_ADMIN_USERNAME"
export FILEMAKER_SERVER_PWORD="YOUR_ADMIN_PASSWORD"
```
The `FILEMAKER_SERVER` username and password must have admin privileges with FileMaker Server since you'll be modifying the SSL configuration.

**Step 3**

Copy the `fms-deploy-hook.sh` file into the certbot directory. Example: 
```
sudo cp fms-deploy-hook.sh /etc/letsencrypt/
# Set the permissions based upon your need, must be executable
sudo chmod +x /etc/letsencrypt/fms-deploy-hook.sh
sudo nano /etc/letsencrypt/fms-deploy-hook.sh

# Set Line 71 to the location of the `.fms_creds` file above
ENV_VAR_FULLPATH="/Users/admin/.fms_creds"
```

**Step 4**

This step is optional and included in case you want to automate the renewal of the SSL certificate.

```
crontab -e

# Example crontab entry, daily at 02:00, based upon the above values
0 2 * * * root /Users/admin/Applications/certbot/renewssl.sh >> /Users/admin/Applications/certbot/renewssl.log 2>&1

crontab -l

# Set the Mac privacy settings per the below article
```

This is a useful link on how to configure `crontab` on your Mac, https://www.geekbitzone.com/posts/2020/macos/crontab/macos-schedule-tasks-with-crontab/

## Usage Instructions

### Create SLL
```
./GetSSL.sh --help
```

*Script requires root privileges for certain functions. Always review the code before running any script as root.*

```
sudo /Users/admin/Applications/cerbot/GetSSL.sh
```
There are a number of options including the ability to use this script in an automation.

### Renew SSL
```
./RenewSSL.sh --help
```
*Script requires root privileges for certain functions. Always review the code before running any script as root.*

```
sudo /Users/admin/Applications/cerbot/RenewSSL.sh
```

If you followed the instructions, the `--deploy-hook` value will already be correct. If you installed the hook in a different location than the above, you'll need to use the `--deploy-hook` option.

The renewal process was designed to run as an automated script.

## Troubleshooting
Confirm all of your files are in the correct location and have the necessary permissions to be referenced or run. Once you have done this, you'll need to work with the individual scripts to troubleshoot.

`GetSSL.sh`, `RenewSSL.sh`, and `fms-deploy-hook.sh` can be run on their own. If there are errors, you will see them in the console. 

### Random Notes
1. In `RenewSSL.sh`, remove the `-q` flag on `certbot renew`. This will allow you to see more of the output to the console.
2. In `RenewSSL.sh`, run `certbot renew` with the `--force-renewal` flag if you want to simulate invoking the deploy hook, `fms-deploy-hook.sh`.
3. Run `fms-deploy-hook.sh` on its own. You can echo all sorts of variables at different points in the process.
4. Start the Mac `Activity Monitor` and filter the processes on `fm`. If you keep this running while `fms-deploy-hook.sh` script is executing, you'll see the processes disappear then restart.

**Enjoy!**