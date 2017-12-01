# Simple Script to start and monitor an  OpenVpn Connection using Python 3.x
# Required : Python 3.x (Windows or Linux), openvpn client up and running
# Feel free to Fork, Edit, Optimize....

# Usefull command to check the VPN connection
# watch -n 10 'traceroute -m 2 www.yahoo.com'
# watch -n 10 'dig +short myip.opendns.com @resolver2.opendns.com'


# import datetime
import time
from urllib.request import urlopen
from json import load
import os

# the amount to wait between check in Minutes
SleepTime = (1 * 60) / 20


# helper used to centralise log method
def log(strline):
    print(formatedtime() + " : " + strline)


# helper to get well Formatted time
# https://stackoverflow.com/questions/415511/how-to-get-current-time-in-python
def formatedtime():
    return time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime())


# get the current public ip
# https://stackoverflow.com/questions/9481419/how-can-i-get-the-public-ip-using-python2-7?noredirect=1&lq=1
def getpublicip():
    return load(urlopen('http://freegeoip.net/json/'))['ip']


# get the current public country code
# https://stackoverflow.com/questions/9481419/how-can-i-get-the-public-ip-using-python2-7?noredirect=1&lq=1
def getpubliccountrycode():
    return load(urlopen('http://freegeoip.net/json/'))['country_code']


# get the current public country
# https://stackoverflow.com/questions/9481419/how-can-i-get-the-public-ip-using-python2-7?noredirect=1&lq=1
def getpubliccountry():
    return load(urlopen('http://freegeoip.net/json/'))['country_name']


# clear the current terminal
def clearscreen():
    os.system('cls' if os.name == 'nt' else 'clear')


# display info
def displayinfo():
    log("========================================================")

    log("Public IP=[" + getpublicip() + "]")
    log("Public Country Code=[" + getpubliccountrycode() + "]")
    log("Public Country=[" + getpubliccountry() + "]")

    log("========================================================")


# main start od the script
clearscreen()
log("Script start")

# simple loop that wait for a keystroke interrupt it with the usual Ctrl-C (SIGINT).
# https://stackoverflow.com/questions/13180941/how-to-kill-a-while-loop-with-a-keystroke
try:
    while True:
        displayinfo()
        time.sleep(SleepTime)
        clearscreen()
except KeyboardInterrupt:
    log("")
    log("KeyboardInterrupt sequence received...ending script")
    log("")
    pass

log("Script end")
