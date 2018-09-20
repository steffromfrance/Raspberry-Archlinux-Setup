#! /bin/sh

#-Installing Docker Hypriot Image to RPI
#-http://blog.hypriot.com

#-Setting up several usefull container
#-More info at https://docs.docker.com/engine/reference/run/
docker container ls
docker image ls

#Good stats to display about container
docker stats --all --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}"

#Testing with hello world
docker run --name hello-world hypriot/armhf-hello-world

#Rpi Portainer : https://store.docker.com/community/images/hypriot/rpi-portainer
docker volume create portainer_data
docker container stop portainer && docker container rm portainer
docker run --name portainer --restart=always -d -p 9000:9000 \
 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data \
 portainer/portainer:arm
 
#Rpi Monitor : https://store.docker.com/community/images/neoraptor/rpi-monitor
docker container stop rpimonitor && docker container rm rpimonitor
docker run -d --name=rpimonitor --restart=always -p 8888:8888 neoraptor/rpi-monitor

#Samba : https://github.com/dastrasmue/rpi-samba   --CONFIRMED WORKING on 2018-08-24 on RPI2
docker container stop rpi2-samba && docker container rm rpi2-samba
docker run --name rpi2-samba -d \
  --restart='always' --hostname 'rpi2-filer' \
  -p 137:137/udp -p 138:138/udp -p 139:139 -p 445:445 -p 445:445/udp \
  -v /media/HDD1000G:/share/HDD1000G -v /var/log:/share/log \
  dastrasmue/rpi-samba:v3 \
  -u "pi:pi" \
  -s "Rpi2 Logs Files (readonly):/share/log:ro" \
  -s "HDD1000G (private for pi):/share/HDD1000G:rw:pi"

#TransmissionOpenVPN : https://github.com/haugene/docker-transmission-openvpn
echo "PUREVPNUSERNAME=myvpnusername" >> /etc/environnement
echo "PUREVPNPWD=myvpnpwd" >> /etc/environnement
docker container stop transmission && docker container rm transmission

#Cloning and building
git clone https://github.com/haugene/docker-transmission-openvpn.git
cd docker-transmission-openvpn
docker build -f Dockerfile.armhf -t  docker-transmission-openvpn:armhf .

docker run --name=transmission --cap-add=NET_ADMIN --device=/dev/net/tun -d \
              -v /media/pi/HDD1000G1/:/data \
              -v /etc/localtime:/etc/localtime:ro \
              -e OPENVPN_PROVIDER=PUREVPN \
              -e OPENVPN_CONFIG=Netherlands1-tcp,Netherlands2-tcp,Norway-tcp,Sweden-tcp \
              -e OPENVPN_USERNAME=$PUREVPNUSERNAME \
              -e OPENVPN_PASSWORD=$PUREVPNPWD \
              -e OPENVPN_OPTS=--inactive 3600 --ping 10 --ping-exit 60 \
              --log-driver json-file \
              --log-opt max-size=10m \
              -p 9091:9091 \
              docker-transmission-openvpn:armhf

docker run --cap-add=NET_ADMIN --device=/dev/net/tun -d \
			  -v /your/storage/path/:/data \
              -v /etc/localtime:/etc/localtime:ro \
              -e OPENVPN_PROVIDER=PIA \
              -e OPENVPN_CONFIG=CA\ Toronto \
              -e OPENVPN_USERNAME=user \
              -e OPENVPN_PASSWORD=pass \
              -e WEBPROXY_ENABLED=false \
              -e LOCAL_NETWORK=192.168.0.0/16 \
              --log-driver json-file \
              --log-opt max-size=10m \
              -p 9091:9091 \
              haugene/transmission-openvpn




#-DuckDns
#-https://store.docker.com/community/images/lsioarmhf/duckdns
docker create --name=duckdns -e PGID=1000 -e PUID=1000  -e SUBDOMAINS=stef2017 \
  -e TOKEN=<MY TOKEN> -e TZ=Europe/Paris   lsioarmhf/duckdns
\
