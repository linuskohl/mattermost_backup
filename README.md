
# mattermost_backup
[![GitHub license](https://img.shields.io/github/license/linuskohl/mattermost_backup.svg?style=popout-square)](https://github.com/linuskohl/mattermost_backup)

## Synopsis

A short bash script to backup [Mattermost](https://mattermost.org)s database and data directory encrypted. 
It stores the backup archives in a specified destination directory. 

### Prerequisites

You only need [gnupg](https://gnupg.org/) and tar installed. 

## Installation
Clone this repository anywhere, most common is ```/usr/local/sbin```
```
cd /usr/local/sbin
git clone https://github.com/linuskohl/mattermost_backup
```
Make the script executable by running
```
chmod +x mattermost_backup.sh
```

### Configure
Adapt the paths and settings in the *mattermost_backup.sh* file to your needs. 

### Create random password file
In order to encrypt the backups you need to generate a file containing your password. If you want to create
a secure, random password you could use the following command, that generates a 500 character long random password and stores it in a key file.
```
gpg --gen-random --armor 2 500 > /etc/mattermost_backup.key
```
Prevent other users from reading or modifying the key
```
chown root:root /etc/mattermost_backup.key
chmod 600 /etc/mattermost_backup.key 
```

## Run
Add the script to you crontab by running
```
crontab -e
```
and appending a line according to you backup schedule. A daily backup at midnight could look like this
```
0 0 * * * /usr/local/sbin/mattermost_backup/mattermost_backup.sh >/dev/null 2>&1
```

### License
The project is licensed under the GPLv3 License. See [LICENSE.txt](https://github.com/linuskohl/mattermost_backup/blob/master/LICENSE.txt) for more details.

### Author
- Linus Kohl, linus@munichresearch.com

