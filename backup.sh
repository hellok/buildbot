#!/bin/bash
#Generic Server Backup With tar

DIR="serverbackup"
DATE=`date +%a-%d-%b-%Y-%I:%M:%S-%p-%Z`
SERVER=`uname -n`

echo "Starting backup for $SERVER..."

mkdir -p /root/$DIR/$DATE

# System Files Backup

echo "Backing up $SERVER /etc..."
tar -cvzPf /root/$DIR/$DATE/$DATE-$SERVER-etc.tar.gz /etc

echo "Backing up $SERVER /home..."
tar -cvzPf /root/$DIR/$DATE/$DATE-$SERVER-home.tar.gz /home

echo "Backing up $SERVER /var/log..."
tar -cvzPf /root/$DIR/$DATE/$DATE-$SERVER-logs.tar.gz /var/log

echo "Backing up $SERVER /var/www..."
tar -cvzPf /root/$DIR/$DATE/$DATE-$SERVER-www.tar.gz /var/www

echo "Dumping $SERVER MySQL databases files..."
mysqldump -u backupdba -pdbapass --all-databases > /var/lib/mysql/alldatabases.sql

echo "Backing up $SERVER MySQL configuration files..."
tar -cvzPf /root/$DIR/$DATE/$DATE-$SERVER-mysql.tar.gz /var/lib/mysql

echo "Done."
