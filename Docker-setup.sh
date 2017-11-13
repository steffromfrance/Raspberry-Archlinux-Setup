#! /bin/sh

#-Installing Docker Hypriot Image to RPI
#-http://blog.hypriot.com

#-Setting up several usefull container

#-DuckDns
#-https://store.docker.com/community/images/lsioarmhf/duckdns
docker create --name=duckdns -e PGID=1000 -e PUID=1000  -e SUBDOMAINS=stef2017 \
  -e TOKEN=<MY TOKEN> -e TZ=Europe/Paris   lsioarmhf/duckdns
