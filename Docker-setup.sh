#! /bin/sh

#-Installing Docker Hypriot Image to RPI
#-http://blog.hypriot.com

#-Setting up several usefull container
#-More info at https://docs.docker.com/engine/reference/run/
docker container ls
docker image ls

#Testing with hello world
docker run --name hello-world hypriot/armhf-hello-world

#Rpi Portainer : https://store.docker.com/community/images/hypriot/rpi-portainer
docker run --name portainer -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer:arm

#-DuckDns
#-https://store.docker.com/community/images/lsioarmhf/duckdns
docker create --name=duckdns -e PGID=1000 -e PUID=1000  -e SUBDOMAINS=stef2017 \
  -e TOKEN=<MY TOKEN> -e TZ=Europe/Paris   lsioarmhf/duckdns
