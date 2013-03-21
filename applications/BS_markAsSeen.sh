#!/bin/bash

#############################################################
##  SCRIPT - MARQUE COMME VU UN FICHIER                    ##
##                                                         ##
## usage: BS_markAsSeen Filename	                   ##
##                                                         ##
#############################################################


# Chargement de la librairie
source ../BSlib.sh

# On encode le nom de fichier passe en parametre
url_encode "$*"
SEEN_FILENAME=$encodedurl

echo "">>$LOGFILE
date >>$LOGFILE
echo $SEEN_FILENAME >> $LOGFILE

## Identification de l'episode
BS_scrapping $SEEN_FILENAME

## Authentification et recuperation du token
BS_auth

##  Verif du statut de l'episode 
BS_episode $BS_url $BS_season $BS_episode

## Si l'episode n'est pas encore marque comme DL , on le marque.
if [ "$BS_has_seen" -eq "1" ]; then
        echo "Tiens cet episode etait deja marque comme Vu" >> $LOGFILE
else
	BS_seen $BS_url $BS_season $BS_episode
fi

## Fin de la session - Destruction du Token
BS_destroy

