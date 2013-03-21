#!/bin/bash

#############################################################
##  SCRIPT - MARQUE COMME DOWNLOADED UN FICHIER            ##
##                                                         ##
## usage: BS_markAsDownloaded Filename                     ##
##                                                         ##
#############################################################


# Chargement de la librairie
source ../BSlib.sh

# On encode le nom de fichier passé en parametre
url_encode "$*"
TR_TORRENT_NAME=$encodedurl

echo "">>$LOGFILE
date >>$LOGFILE
echo $TR_TORRENT_NAME >> $LOGFILE

## Identification de l'episode
BS_scrapping $TR_TORRENT_NAME

## Authentification et recuperation du token
BS_auth

##  Verif du statut de l'episode 
BS_episode $BS_url $BS_season $BS_episode

## Si l'episode n'est pas encore marqué comme DL , on le marque.
if [ "$BS_downloaded" -eq "1" ]; then
        echo "Tiens cet episode etait deja marqué comme Downloaded" >> $LOGFILE
else
	BS_downloaded $BS_url $BS_season $BS_episode
fi

## Fin de la session - Destruction du Token
BS_destroy
