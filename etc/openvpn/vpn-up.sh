#!/usr/bin/bash
PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$HOME/bin
echo "Executing vpn-up.sh script"
 
echo "Stopping Transmission-Daemon and waiting a little..."
systemctl stop transmission
sleep 2
#echo "Starting Transmission-Daemon..."
#systemctl start transmission
#echo "Started Transmission-Daemon..."
 
#echo "Stopping Deluged Daemon and waiting a while...."
#systemctl stop deluged
#sleep 2
#echo "Starting Deluged Daemon..."
#systemctl start deluged
#echo "Started Deluged Daemon..."
 
echo "Current Public IP : "
curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
 
echo "Script vpn-up.sh executed successfully"
