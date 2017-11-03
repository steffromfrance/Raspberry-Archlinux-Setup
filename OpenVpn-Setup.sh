#! /bin/sh
#-Installing and configuring my OpenVpn connection
# https://support.purevpn.com/linux-openvpn-command/
#watch -n 10 'dig +short myip.opendns.com @resolver2.opendns.com'
watch -n 10 'dig +short myip.opendns.com @resolver2.opendns.com'

mkdir -p /var/log/openvpn/client
mkdir -p /etc/openvpn/client
cd /etc/openvpn/
rm vpn-*.sh
wget https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/openvpn/vpn-down.sh
wget https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/openvpn/vpn-up.sh
chmod u+x vpn-*.sh
cd /etc/openvpn/client
rm *.sh 
wget https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/openvpn/client/monitor-openvpn-connection.sh 
wget https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/openvpn/client/start-purevpn.sh
chmod u+x *.sh
wget https://s3-us-west-1.amazonaws.com/heartbleed/linux/linux-files.zip
unzip linux-files.zip 
cp Linux\ OpenVPN\ Updated\ files/ca.crt ./ca.crt
cp Linux\ OpenVPN\ Updated\ files/Wdc.key ./Wdc.key
nano auth.txt
ln -sf Linux\ OpenVPN\ Updated\ files/TCP/Netherlands1-tcp.ovpn client.conf
./monitor-openvpn-connection.sh
./start-purevpn.sh
tail -f /var/log/openvpn/client
