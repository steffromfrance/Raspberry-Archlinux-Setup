#! /bin/sh
# Simple script to store all the necessary steps to setup my ArchLinux ARM on my raspberry 2

#-Get The image at https://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2
#-Burn It to the SD card
#-A good site that store all the tips is http://archpi.dabase.com

#-Making a general update of the system
pacman -Syu

#-Installing necessary stuff
pacman -S sudo htop git pkgfile base-devel tmux samba openvpn pptpclient nmon wget unzip zip zsh dnsutils

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

#-Enabling ssh root login
#-https://askubuntu.com/questions/469143/how-to-enable-ssh-root-access-on-ubuntu-14-04#489034
sudo passwd




#-Adding other stuff
yaourt -S xfce4 xfce4-goodies



#-Installing Shellinabox
yaourt shellinabox-git
systemctl enable shellinabox-git && systemctl start shellinabox-git
