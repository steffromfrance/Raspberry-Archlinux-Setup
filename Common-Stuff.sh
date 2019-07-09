# Some Stuff common to all distribution


#-Setup for RealVnc server in Headless Mode
# https://www.realvnc.com/fr/connect/docs/raspberry-pi.html
# forcing HDMI output
#https://www.raspberrypi.org/documentation/configuration/config-txt/video.md
sudo mount -o remount,rw /boot

nano /boot/config.txt
hdmi_force_hotplug=1
hdmi_ignore_edid=0xa5000080
hdmi_group=2
hdmi_mode=23

sudo mount -o remount,ro /boot
sudo reboot

--Enabling the boot on usb on a RPI
echo program_usb_boot_mode=1 | sudo tee -a /boot/config.txt
This adds program_usb_boot_mode=1 to the end of /boot/config.txt. Reboot the Raspberry Pi with sudo reboot, then check that the OTP has $ vcgencmd otp_dump | grep 17:
17:3020000a

--Disabling swapping on the swap
sudo dphys-swapfile swapoff && sudo dphys-swapfile uninstall && sudo systemctl disable dphys-swapfile

# Setting some user/password in a Environnement variable so it can be access by all scripts
sudo nano /etc/environment
....
FREE_FTP_USER=stef2018
FREE_FTP_PWD=MYPASSWORD


#-Installting and configuraing lftp
# http://www.russbrooks.com/2010/11/19/lftp-cheetsheet
sudo apt install lftp
#
sudo echo 'FREE_FTP_USER=stef2018'  >> /etc/environment
sudo echo 'FREE_FTP_PWD=password'  >> /etc/environment
sudo reboot

lftp -u $FREE_FTP_USER,$FREE_FTP_PWD ftpperso.free.fr
mkdir  stef2001-ubuntu001
CD stef2001-ubuntu001
lftp -e 'mirror -R /var/lib/monitorix/www/imgs/ /stef2001-ubuntu001/monitorix/' -u $FREE_FTP_USER,$FREE_FTP_PWD ftpperso.free.fr


#-Settings Samba
cd /etc/samba
rm smb.conf && rm smbusers
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/samba/smb.conf
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/samba/smbusers
systemctl enable smbd && systemctl start smbd
systemctl enable nmbd && systemctl start nmbd
systemctl stop nmbd && systemctl stop smbd
systemctl restart smbd && systemctl restart nmbd
smbpasswd -a alarm
smbpasswd -a pi
smbpasswd -a pirate


#-Mounting my External Hard Drive
mkdir -p /media/HDD1000G
echo "UUID=eebde59c-f5ea-45bb-8671-71e1d4468094 /media/HDD1000G ext4 noatime,nofail 0 0" >> /etc/fstab
mount -a ext4
sudo chown pi:pi -Rv /media/HDD1000G
sudo chmod 666 -Rv /media/HDD1000G

#-Mounting a samba shared drive
#-https://wiki.ubuntu.com/MountWindowsSharesPermanently
mkdir -p /media/HDD1000G
echo -e 'username=msusername\npassword=mspassword\n' > ~/.smbcredentials
chmod 600 ~/.smbcredentials
echo '//192.168.0.100/HDD1000G /media/HDD1000G cifs credentials=/root/.smbcredentials,nofail,iocharset=utf8,file_mode=0770,dir_mode=0770,gid=1000,uid=1000 0 0 ' >> /etc/fstab

mount -a -v
mount.cifs //192.168.0.100/HDD1000G /media/HDD1000G user=pi,pass=PASSWORD,iocharset=utf8,file_mode=0770,dir_mode=0770,gid=1000,uid=1000

#-Installing a configuring conky
apt install conky
mkdir -p /etc/conky
cd /etc/conky
wget https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/conky/conky-partmagic.conf
conky -d -c /etc/conky/conky-partmagic.conf

#-Installing LXDE
# https://wiki.archlinux.org/index.php/LXDE
apt-get install xfce4 xfce4-goodies

#-Installing vncserver
#-Configuring the desktop https://support.realvnc.com/Knowledgebase/Article/View/345/0/
apt-get install realvnc-vnc-server
vncserver
vncserver -kill :1


#-using the old vmc server
cd /home/alarm/.vnc
rm xstartup
wget  https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/home/alarm/.vnc/xstartup
chmod u+x xstartup
rm config
https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/home/alarm/.vnc/config
sudo loginctl enable-linger pi
systemctl --user enable vncserver@:1
systemctl --user start vncserver@:1


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

#-Generating and installing self-signed certificate
# https://wiki.archlinux.org/index.php/Nginx#TLS.2FSSL
apt install nginx

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

#-Installtin and setting up Monitorix
#-http://www.monitorix.org/
echo deb http://apt.izzysoft.de/ubuntu generic universe  >> /etc/apt/sources.list
wget http://apt.izzysoft.de/izzysoft.asc
sudo apt-key add izzysoft.asc
sudo apt update
sudo apt install monitorix
sudo systemctl disable monitorix
#-Generating HTML files
cd /var/lib/monitorix/www/cgi
./monitorix.cgi mode=localhost graph=all when=day color=black
