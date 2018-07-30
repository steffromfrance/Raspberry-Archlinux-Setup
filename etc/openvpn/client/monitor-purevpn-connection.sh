#! /bin/bash
# Simple Script to start and monitor an  PureVPN Connection ,(the PureVPN command line client need to be OK)
# Feel free to Fork, Edit, Optimize....
# Usefull command to check the VPN connection
# watch -n 10 'traceroute -m 2 www.yahoo.com'
# watch -n 10 'dig +short myip.opendns.com @resolver2.opendns.com'
 
#SLEEPTIME is the amount to wait between check
SLEEPTIME=1m
PUBLICIPTOHIDE="77.136."
NBCONN=0
 
# Helper to direcly log message to console and log file
function log 
{
  #TODO : see if we can optimize this function
  LOGFILE="purevpn-client-$(date +%Y-%m).log"
  STRLINE="$(date "+%a %b %d %H:%M:%S %Y ") $1"
  echo "$STRLINE" & echo "$STRLINE" >> "$LOGFILE"
  chmod 666 "$LOGFILE"
 }
 
# Function that start the pure vpn Connection
function startconn 
{
 let NBCONN++
 #choosing a random country
 array[0]="NL"
 array[1]="NO"
 array[2]="SE"
 size=${#array[@]}
 index=$(($RANDOM % $size))
 log "Connecting to : [${array[$index]}] PureVPN Country"
 
 purevpn -c ${array[$index]}
 STR="PUREVPN CONNECTION Started at $(date +%Y-%m-%d-%k-%M-%S)"
 log "$STR"
 log "NUMBER OF (RE)-CONNECTION : $NBCONN (since start of the script)"
 
}
 
#function that stop all the purevp Connection
function stopconn
{
 purevpn -d
 STR="PUREVPN CONNECTION Closed  at $(date +%Y-%m-%d-%k-%M-%S)"
 log "$STR"
}
 
#Function for trapping the end signal
function trap_finish {
 log "Exit signal received..."
 stopconn
}
trap trap_finish EXIT
 
 
#Check if  a string $2 is   a substring of another string $1
#Return 1 if $2 is found in $1, 0 if not found
function is_substring
{
my_string=$1
substring=$2
STRFOUND=0
if [ "${my_string/$substring}" = "$my_string" ] ; then
  #echo "DEBUG-[${substring}] is not in [${my_string}]"
  STRFOUND=0
else
  #echo "DEBUG-[${substring}] was found in [${my_string}]"
  STRFOUND=1
fi
 
#echo "DEBUG-STRFOUND=$STRFOUND"
return $STRFOUND
}
 
#Function that test if the VPN connection is UP and if the Public IP is hidden
#Return values : 
# 0  public ip is hidden
# 1  public ip is not hidden 
# 2  not enable to get external ip
function checkvpnok
{
  RETURNVALUE=2
  EXTERNALIP=$(dig +short myip.opendns.com @resolver2.opendns.com)
  #log "IPTOHIDE=[$PUBLICIPTOHIDE] CURRENT PUBLIC=[$EXTERNALIP]"
  if [ -z "$EXTERNALIP" ]
  then
    RETURNVALUE=1
    log "CHECKVPNOK : ERROR  (not able to get external IP )"
    return $RETURNVALUE
  fi
 
  is_substring "$EXTERNALIP" "$PUBLICIPTOHIDE"
  IPFOUND=$?
 
  #echo "DEBUG-IPFOUND=[$IPFOUND]"
 
  if [ $IPFOUND == "1" ]
  then
   #echo "KO : Public IP is not hidden"
   log "CHECKVPNOK : KO_PUBLIC_IP_NOT_HIDDEN (EXTERNALIP=[$EXTERNALIP] PUBLICIPTOHIDE=[$PUBLICIPTOHIDE])"
   RETURNVALUE=1
  else
   #echo "OK : Public IP is hidden"
   log "CHECKVPNOK : OK_PUBLIC_IP_HIDDEN (EXTERNALIP=[$EXTERNALIP] PUBLICIPTOHIDE=[$PUBLICIPTOHIDE])"
   RETURNVALUE=0
  fi
 
  #echo "DEBUG-RETURNVALUE=$RETURNVALUE"
  return $RETURNVALUE
}
 
 
#MAIN PROGRAM
echo "Simple script that start and monitor an PureVPN connection endlessly"
echo "Hit [CTRL+C] to stop !"
stopconn
 
while true
do
 checkvpnok
 #if public IP is not hidden or if there is a problem on the connection, restarting the OpenVpn Client
 PUBLICIPHIDDEN=$?
 if [ $PUBLICIPHIDDEN == "1" ]
 then
  startconn
 fi
 #Waiting for sometime
 sleep $SLEEPTIME
done
 
#Stopping connections before exiting
stopconn
 
exit 0
