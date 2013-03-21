#!/bin/bash

# Script a lancer periodiquement (via cron par exemple) pour analyser les logs de minidlna et en déduire les episodes vus.
# Ce script ne fonctionne que si minidlna est execute en mode verbeux (parametre -v passe a l exécution)


cat /var/log/minidlna.log |grep Serving |grep -v .srt|cut -d[ -f3|cut -d] -f1 > /tmp/DLNAlist

cat /tmp/DLNAlist | while read line
do
./BS_markAsSeen.sh $line
done
