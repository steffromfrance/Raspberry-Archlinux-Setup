#! /bin/sh
# Simple script to store all the necessary steps to setup my ArchLinux ARM on my raspberry 2

#-Get The image at https://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2
#-Burn It to the SD card
#-A good site that store all the tips is http://archpi.dabase.com

#-Making a general update of the system
pacman -Syu

#-Installing necessary stuff 
pacman -S sudo htop git pkgfile base-devel tmux samba openvpn pptpclient nmon wget

#-Adding alarm to the sudoers users (https://stackoverflow.com/questions/12736351/exit-save-edit-to-sudoers-file-putty-ssh)

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

#-Mounting my External Hard Drive
mkdir -p /media/HDD1000G
echo "UUID=eebde59c-f5ea-45bb-8671-71e1d4468094 /media/HDD1000G ext4 noatime,nofail 0 0" >> /etc/fstab
mount -a ext4
sudo chown alarm:alarm -Rv /media/HDD1000G
sudo chmod 550 -Rv /media/HDD1000G


#-Adding other stuff
yaourt -S xfce4 xfce4-goodies
yaourt -S nginx

#-Settings Samba
cd /etc/samba
rm smb.conf && rm smbusers
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/samba/smb.conf
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/samba/smbusers
systemctl enable smbd && systemctl start smbd
systemctl enable nmbd && systemctl start nmbd
smbpasswd -a alarm
smbpasswd -a pi

#-Installing Gateone
yaourt gateone
sudo gateone
