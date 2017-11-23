#! /bin/bash
# Simple Script to start and monitor an  OpenVpn Connection using Python 3.x
# Required : Python 3.x (Windows or Linux), openvpn client up and running
# Feel free to Fork, Edit, Optimize....

# Usefull command to check the VPN connection
# watch -n 10 'traceroute -m 2 www.yahoo.com'
# watch -n 10 'dig +short myip.opendns.com @resolver2.opendns.com'
 
#SLEEPTIME is the amount to wait between check

import datetime
from time import gmtime, strftime
from urllib.request import urlopen
from json import load

#helper used to centralise log method
def log(logline):
    print (formatedtime() +  " : " + logline)

#helper to get well formated time
#https://stackoverflow.com/questions/415511/how-to-get-current-time-in-python
def formatedtime():
    return strftime("%Y-%m-%d %H:%M:%S", gmtime())

#get the current public ip
#https://stackoverflow.com/questions/9481419/how-can-i-get-the-public-ip-using-python2-7?noredirect=1&lq=1
def getpublicip():
    return load(urlopen('http://freegeoip.net/json/'))['ip'] 

#get the current public country code
#https://stackoverflow.com/questions/9481419/how-can-i-get-the-public-ip-using-python2-7?noredirect=1&lq=1
def getpubliccountrycode():
    return load(urlopen('http://freegeoip.net/json/'))['country_code'] 

#get the current public country
#https://stackoverflow.com/questions/9481419/how-can-i-get-the-public-ip-using-python2-7?noredirect=1&lq=1
def getpubliccountry():
    return load(urlopen('http://freegeoip.net/json/'))['country_name'] 

log("Script start")
log("Public IP=[" + getpublicip()+ "]")
log("Public Country Code=[" + getpubliccountrycode()+ "]")
log("Public Country=[" + getpubliccountry()+ "]")
log("Script end")