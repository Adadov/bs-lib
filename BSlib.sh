#!/bin/bash

# Clef API Betaseries
BS_apikey=

# Fichier log
LOGFILE="/var/log/Betaseries"
#LOGFILE="/dev/stdout"

# Credentials utilisateur Betaseries
BS_user="Dev010"
BS_pw="developer"

#############################################################
##  FONCTION -  AUTHENTIFICATION                           ##
##                                                         ##
## usage: BS_verifcode etape			           ##
## retour : RAS/ exit sur erreur avec affichage erreur     ##
##							   ##
#############################################################
function BS_verifcode
{
        code=`cat /tmp/dumpBS.out|grep code|cut -d\> -f2|cut -d\< -f1|tail -n1`

	if [ "$code" -eq "1" ]; then
        	echo $1 OK >>$LOGFILE
        	#cat /tmp/dumpBS.out>>$LOGFILE
	else
        	echo "erreur $1 - code $code">>$LOGFILE
        	cat /tmp/dumpBS.out >>$LOGFILE
        	exit
	fi
}


#############################################################
##  FONCTION -  AUTHENTIFICATION                           ##
##                                                         ##
## usage: BS_auth		                           ##
## la variable globale $BS_token est definie si auth OK    ##
#############################################################

function  BS_auth
{
	md5pw=`echo -n $BS_pw |openssl md5`
	curl -s api.betaseries.com/members/auth.xml?key=$BS_apikey\&login=$BS_user\&password=$md5pw >/tmp/dumpBS.out
	BS_verifcode AUTHENTIFICATION
	BS_token=`cat /tmp/dumpBS.out|grep token|cut -d\> -f2|cut -d\< -f1`
	return $code
}


#############################################################
##  FONCTION -  SCRAPPING                                  ##
##                                                         ##
## usage: BS_scrap nom_du_fichier	                   ##
## defininles variables globales $url $episode $saison     ##
#############################################################

function BS_scrapping
{
	curl -s api.betaseries.com/shows/scraper.xml?key=$BS_apikey\&file=$1 >/tmp/dumpBS.out
	BS_verifcode SCRAPPING
        BS_url=`cat /tmp/dumpBS.out|grep url|cut -d\> -f2|cut -d\< -f1`
        BS_season=`cat /tmp/dumpBS.out|grep season|cut -d\> -f2|cut -d\< -f1`
        BS_episode=`cat /tmp/dumpBS.out|grep episode|cut -d\> -f2|cut -d\< -f1`
        BS_number=`cat /tmp/dumpBS.out|grep number|cut -d\> -f2|cut -d\< -f1`
}

#############################################################
##  FONCTION - EPISODE                                     ##
##                                                         ##
## usage: BS_episodes url_serie saison Episode             ##
## definini les variables $BS_has_seen $BS_downloded       ##
#############################################################

function BS_episode
{
	curl -s http://api.betaseries.com/shows/episodes/$1.xml?key=$BS_apikey\&token=$BS_token\&season=$2\&episode=$3\&hide_notes=1\&summary=1 >/tmp/dumpBS.out
        BS_verifcode INFO_EPISODE
        BS_has_seen=`cat /tmp/dumpBS.out|grep has_seen|cut -d\> -f2|cut -d\< -f1`
        BS_downloaded=`cat /tmp/dumpBS.out|grep downloaded|cut -d\> -f2|cut -d\< -f1`
}

#############################################################
##  FONCTION - MARQUE COMME DOWNLOADED                     ##
##                                                         ##
## usage:                                                  ##
## BS_downloaded url_serie saison Episode                  ##
#############################################################

function BS_downloaded
{
        curl -s http://api.betaseries.com/members/Downloaded/$1.xml?key=$BS_apikey\&token=$BS_token\&season=$2\&episode=$3 >/tmp/dumpBS.out
        BS_verifcode MARK_DL
}

#############################################################
##  FONCTION - DESTRUCTION DU TOKEN                        ##
##                                                         ##
## usage:                                                  ##
## BS_destroy					           ##
#############################################################

function BS_destroy
{

        curl -s http://api.betaseries.com/members/destroy.xml?key=$BS_apikey\&token=$BS_token >/tmp/dumpBS.out
        BS_verifcode DESTROY_TOKEN
}

#############################################################
##  FONCTION - MARQUE COMME VU                             ##
##                                                         ##
## usage:                                                  ##
## BS_seen url_serie saison Episode 		           ##
#############################################################

function BS_seen
{
        curl -s http://api.betaseries.com/members/watched/$1.xml?key=$BS_apikey\&token=$BS_token\&season=$2\&episode=$3 >/tmp/dumpBS.out
        BS_verifcode MARK_SEEN
}



#############################################################
##  FONCTION - ENCODAGE URL                                ##
##                                                         ##
## usage:                                                  ##
## url_encode chaine                                       ##
#############################################################


url_encode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
#  echo "${encoded}"    # You can either set a return variable (FASTER) 
  encodedurl="${encoded}"   #+or echo the result (EASIER)... or both... :p
}
