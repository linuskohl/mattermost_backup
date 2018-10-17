#!/bin/bash -
#title           : mattermost_backup
#description     : This script will create encrypted backups for mattermost
#author          : Linus Kohl, linus@munichresearch.com
#date            : 2018_10_17
#version         : 0.1
#usage           : See README.md
#notes           :
#==============================================================================
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

DATESTRING=`date +"%F_%H-%m-%S"`
DEPENDENCIES=(gpg tar)
OUTPUT_DIRECTORY=/tmp
CIPHER_ALGO=AES256
PASSWORD_FILE=/root/passphrase
MATTERMOST_USER=mattermost
MATTERMOST_DB=mattermost_production
MATTERMOST_DB_USER=gitlab_mattermost
MATTERMOST_DB_PORT=5432
MATTERMOST_SOCKET=/var/opt/gitlab/postgresql
MATTERMOST_PGDUMP=/opt/gitlab/embedded/bin/pg_dump
MATTERMOST_DATA=/var/opt/gitlab/mattermost/data


# check that we are root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo "Please run as root"
        exit 1
    fi
}

# check that nobody has access to the password file
check_password_permissions() {
    perm=$(stat -c %a "$PASSWORD_FILE" 2>/dev/null)
    if [ ! "$perm" = "600" ]; then
        echo "Please set permissions on your password file to 600"
        exit 1
    fi
}

check_installed() {
    if ! hash $1 2>/dev/null; then
       echo "$1 not installed"
       exit 1
    fi
}

# backup mattermost database
backup_database() {
  echo "Exporting database $MATTERMOST_DB"

  sudo -u $MATTERMOST_USER \
          $MATTERMOST_PGDUMP -U $MATTERMOST_DB_USER -h $MATTERMOST_SOCKET -p $MATTERMOST_DB_PORT $MATTERMOST_DB | \
  gpg --batch --yes --symmetric --cipher-algo $CIPHER_ALGO --passphrase-file=$PASSWORD_FILE  > $OUTPUT_DIRECTORY/$DATESTRING-mattermost_database.sql.gpg
}

# backup mattermost data directory 
backup_data() {
  echo "Backing up Mattermost data directory $MATTERMOST_DATA"

  tar -cz -C $MATTERMOST_DATA . | \
  gpg --batch --yes --symmetric --cipher-algo $CIPHER_ALGO --passphrase-file=$PASSWORD_FILE > $OUTPUT_DIRECTORY/$DATESTRING-mattermost_data.tar.gz.gpg
}

# check if required applications are installed
for d in "${DEPENDENCIES[@]}"; do
    check_installed $d    
done

if [[ -f $PASSWORD_FILE && -r $PASSWORD_FILE ]]; then
    check_password_permissions
else
    echo "Password file does not exist or can not be read"
    exit 1
fi

check_root

# check output directory is writable
if [[ ! -d "${OUTPUT_DIRECTORY}" || ! -w "${OUTPUT_DIRECTORY}" ]] ; then
    echo "$OUTPUT_DIRECTORY is not a directory or not writable";
    exit 1
fi

backup_database
backup_data

exit 0

