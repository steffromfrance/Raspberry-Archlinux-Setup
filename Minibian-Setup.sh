#! /bin/sh
# Simple script to store all the necessary steps to setup my Minibian ARM on my raspberry 1/2/3

#-Get The image at https://minibianpi.wordpress.com
#-Burn It to the SD card using DD
#-Default user is root : raspberry

#-Using Noob, need to enable ssh by creatin a ssh file on the root
users: root/raspberry

#-Installing necessary stuff
apt-get install raspi-config tmux
#Expanding the user space to the entire sd card
raspi-config
apt-get dist-upgrade
apt-get install sudo perl htop git openvpn wget unzip zip zsh
apt-get install dnsutils nmon nano cifs-utils traceroute mc ncdu samba

#-Creating user
sudo adduser pi
#-Adding alarm to the sudoers users (https://stackoverflow.com/questions/12736351/exit-save-edit-to-sudoers-file-putty-ssh)
visudo
#Navigate to the place you wish to edit using the up and down arrow keys.
#Press insert to go into editing mode.
#Make your changes - for example: user ALL=(ALL) ALL.
#Note - it matters whether you use tabs or spaces when making changes.
#Once your changes are done press esc to exit editing mode.
#Now type :wq to save and press enter.

#-Generating locale
sudo nano /etc/locale.gen
sudo locale-gen
sudo nano /etc/locale.conf  (set LANG = fr_FR.UTF-8 or other)
sudo shutdown -r now

#-Enabling ssh root login
#-https://askubuntu.com/questions/469143/how-to-enable-ssh-root-access-on-ubuntu-14-04#489034
sudo passwd

#-Defining an Static IP Adress
# https://www.howtogeek.com/howto/ubuntu/change-ubuntu-server-from-dhcp-to-a-static-ip-address/
nano /etc/network/interfaces
auto eth0
iface eth0 inet static
address 192.168.0.10
netmask 255.255.255.0
network 192.168.0.0
broadcast 192.168.0.255
gateway 192.168.0.1
dns-nameservers 192.168.0.1
ifdown eth0 && ifup eth0

# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'
nano /etc/dhcpd.conf
