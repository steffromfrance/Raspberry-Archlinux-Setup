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
mount_smbfs -O freebsd:freebsd -I 192.168.0.100 //pi@192.168.0.100/HDD1000G /media/HDD1000G



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

#-Initialising Ports Collection
#-https://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/ports-using.html
portsnap fetch
portsnap extract
portsnap fetch update



#-INstalling a DE
sudo pkg install fluxbox
#https://fosskb.in/2016/02/15/installing-mate-desktop-on-freebsd-11/

#-XFCE4
#-https://www.freshports.org/x11-wm/xfce4/
cd /usr/ports/x11-wm/xfce4/ && make install clean
pkg install xfce
