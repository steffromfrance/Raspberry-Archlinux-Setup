#! /bin/sh
# Simple script to store all the necessary steps to setup FreeBSD ARM on my raspberry 1/2/3

#============================    FREEBSD  ==========================================
# 01-Choosing the right image disk https://www.freebsd.org/where.html
#-02-Burning the img using DD or other
nano config.txt
#-forcing the hdmi output https://elinux.org/RPiconfig
# -using a valid pal config in order to use it on PAL
nano config.txt
# Set sdtv mode to PAL (as used in Europe)
sdtv_mode=2
# Force the monitor to HDMI mode so that sound will be sent over HDMI cable
hdmi_drive=2
# Set monitor mode to DMT
hdmi_group=2
# Set monitor resolution to 1024x768 XGA 60 Hz (HDMI_DMT_XGA_60)
hdmi_mode=16
# Make display smaller to stop text spilling off the screen
overscan_left=20
overscan_right=12
overscan_top=10
overscan_bottom=10


#-Getting doc on https://www.freebsd.org/doc/handbook/basics.html
# Connect to SSH : freebsd/freebsd or root/root 

#-installing some stuff
pkg install sudo zsh
pkg install htop git tmux openvpn wget unzip zip nano mc
pkg install bind-tools

#-Creating user
adduser pi
pw groupmod  wheel -m pi 

visudo
#Navigate to the place you wish to edit using the up and down arrow keys.
#Press insert to go into editing mode.
#Make your changes - for example: user ALL=(ALL) ALL.
#Note - it matters whether you use tabs or spaces when making changes.
#Once your changes are done press esc to exit editing mode.
#Now type :wq to save and press enter.

# Loading the tun kermodule to allow openvpn conncetion
# and resolve error openvpn[1264]: Cannot allocate TUN/TAP dev dynamically
# ref : http://www.freebsddiary.org/openvpn.php
sudo kldload if_tun
#To ensure this module is loaded at boot time, add the following line to /boot/loader.conf:
if_tun_load="YES"




#-Defining an Static IP Adress in FreeBSD
# https://superuser.com/questions/151735/how-to-set-static-ip-address-on-the-freebsd-machine
sysrc ifconfig_DEFAULT="inet 192.168.0.10 netmask 255.255.255.0 broadcast 192.168.0.255"
sysrc defaultrouter="192.168.0.1"
reboot now


dns-nameservers 192.168.0.1


#-Mounting my External Hard Drive
mkdir -p /media/HDD1000G
echo "UUID=eebde59c-f5ea-45bb-8671-71e1d4468094 /media/HDD1000G ext4 noatime,nofail 0 0" >> /etc/fstab
mount -a ext4
sudo chown root:root -Rv /media/HDD1000G
sudo chmod 666 -Rv /media/HDD1000G

#-Mounting a samba shared drive on FreeBsd
#-http://blog.up-link.ro/freebsd-how-to-mount-smb-cifs-shares-under-freebsd/
mkdir -p /media/HDD1000G
mount_smbfs -O freebsd:freebsd -I 192.168.0.10 //pi@192.168.0.10/HDD1000G /media/HDD1000G



# Installing python an pip
# https://nerd.h8u.net/2016/01/29/installing-python-package-manager-pip-on-freebsd/
pkg install python python3
python -m ensurepip

# Installing Glances
# https://github.com/nicolargo/glances/blob/master/README.rst
sudo pip install glances
sudo pip install bottle
# http://glances.readthedocs.io/en/stable/quickstart.html
# launching Web Server Mode
glances -w  # the type http://@server:61208
glances --theme-white

#-INstalling and configuring transmission
# https://wiki.archlinux.org/index.php/Transmission
yaourt transmission-cli
yaourt transmission-remote-cli-git
yaourt python2-geoip
yaourt adns-python
sudo systemctl enable transmission
sudo systemctl start transmission
sudo systemctl stop transmission
cd /var/lib/transmission/.config/transmission-daemon
rm settings.json
wget https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/var/lib/transmission/.config/transmission-daemon/settings.json

#-Installing LXDE
# https://wiki.archlinux.org/index.php/LXDE
apt-get install xfce4 xfce4-goodies

#-Installing vncserver
#-Configuring the desktop https://support.realvnc.com/Knowledgebase/Article/View/345/0/
apt-get install realvnc-vnc-server
vncserver
vncserver -kill :1


cd /home/alarm/.vnc
rm xstartup
wget  https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/home/alarm/.vnc/xstartup
chmod u+x xstartup
rm config
https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/home/alarm/.vnc/config
sudo loginctl enable-linger pi
systemctl --user enable vncserver@:1
systemctl --user start vncserver@:1

#-Installing and configuring novnc
#-https://github.com/novnc/noVNC
git clone https://github.com/novnc/noVNC.git
cd noVNC
./utils/launch.sh --vnc localhost:5901


#-Installing and configuring my OpenVpn connection
# https://support.purevpn.com/linux-openvpn-command/
mkdir -p /var/log/openvpn/client
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
cp Linux\ OpenVPN\ Updated\ files/ca.crt ./ca.crt
cp Linux\ OpenVPN\ Updated\ files/Wdc.key ./Wdc.key
nano auth.txt
ln -sf Linux\ OpenVPN\ Updated\ files/TCP/Netherlands1-tcp.ovpn clien.conf
bash monitor-openvpn-connection.sh
tail -f /var/log/openvpn/client


