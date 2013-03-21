#!/bin/bash

# Script a lancer periodiquement (via cron par exemple) pour analyser les logs du client bittorent transmission et en déduire les episodes téléchargés.

cat /var/log/syslog |grep transmission |grep moving |cut -d\  -f6 > /tmp/DLlist

cat /tmp/DLlist | while read line
do
./BS_markAsDownloaded.sh $line
done
