#!/usr/bin/bash
PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$HOME/bin
 
echo "Executing script vpn-down.sh"
#/bin/iptables -t nat -D POSTROUTING -o tun0 -j MASQUERADE
 
echo "Stopping Transmission-Daemon and waiting a little..."
systemctl stop transmission
sleep 1
echo "Transmission-Daemon Stopped..."
echo "Stopping Any QBitorrent Client..."
su pi -c 'killall qbittorrent'
echo "Any QBittorrent killed.."
echo "Stopping Any Transmission-Gtk Client..."
su pi -c 'killall transmission-gtk'
echo "Any Any Transmission-Gtk killed.."
 
echo "Stopping Deluged Daemon and waiting for a while..."
systemctl stop deluged
sleep 1
echo "Stopped Deluged Daemon..."
 
echo "Script vpn-down.sh executed successfully"
