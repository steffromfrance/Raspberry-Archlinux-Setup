#! /bin/sh
# Simple script to store all the necessary steps to setup my Minibian ARM on my raspberry 1/2/3

#-Get The image at https://minibianpi.wordpress.com
#-Burn It to the SD card using DD
#-Default user is root : raspberry


#-Installing necessary stuff
apt-get update
apt-get dist-upgrade
apt-get install sudo htop git pkgfile base-devel tmux openvpn pptpclient wget unzip zip zsh dnsutils nmon


#-Creating user alarm
sudo adduser alarm
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

#-Building yaourt (https://archlinux.fr/yaourt-en) AS standard user (not root)
git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg -si
cd ..
git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -si
cd ..

#-Enabling ssh root login
#-https://askubuntu.com/questions/469143/how-to-enable-ssh-root-access-on-ubuntu-14-04#489034
sudo passwd



#-Mounting my External Hard Drive
mkdir -p /media/HDD1000G
echo "UUID=eebde59c-f5ea-45bb-8671-71e1d4468094 /media/HDD1000G ext4 noatime,nofail 0 0" >> /etc/fstab
mount -a ext4
sudo chown alarm:alarm -Rv /media/HDD1000G
sudo chmod 550 -Rv /media/HDD1000G


#-Adding other stuff
yaourt -S xfce4 xfce4-goodies

#-Settings Samba
cd /etc/samba
rm smb.conf && rm smbusers
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/samba/smb.conf
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/samba/smbusers
systemctl enable smbd && systemctl start smbd
systemctl enable nmbd && systemctl start nmbd
smbpasswd -a alarm
smbpasswd -a pi

#-Installing Shellinabox
yaourt shellinabox-git
systemctl enable shellinabox-git && systemctl start shellinabox-git

#-Installing Nginx and setting up reverse proxy
yaourt -S nginx

#-Generating and installing self-signed certificate
# https://wiki.archlinux.org/index.php/Nginx#TLS.2FSSL
cd /etc/nginx
rm nginx.conf
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/nginx/nginx.conf
mkdir /etc/nginx/ssl
cd /etc/nginx/ssl
openssl req -new -x509 -nodes -newkey rsa:4096 -keyout server.key -out server.crt -days 1095
chmod 400 server.key
chmod 444 server.crt
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/nginx/ssl/server.crt
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/nginx/ssl/server.key
systemctl restart nginx

#-Installin ezServerMonitor
sudo -i
cd /usr/share/nginx/html/
wget https://www.ezservermonitor.com/esm-web/downloads/version/2.5
unzip -o -d ./ 2.5
rm 2.5

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
sudo pacman -S lxde gvfs xarchiver

#-Installing vncserver
# https://wiki.archlinux.org/index.php/TigerVNC
sudo pacman -S tigervnc
vncserver
vncserver -kill :1
cd /home/alarm/.vnc
rm xstartup
wget  https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/home/alarm/.vnc/xstartup
chmod u+x xstartup
rm config
https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/home/alarm/.vnc/config
sudo loginctl enable-linger alarm
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


