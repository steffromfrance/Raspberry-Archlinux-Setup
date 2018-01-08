# Simple Script to start and monitor an  OpenVpn Connection using Python 3.x
# Required : Python 3.x (Windows or Linux), openvpn client up and running
# Feel free to Fork, Edit, Optimize....

# Usefull command to check the VPN connection
# watch -n 10 'traceroute -m 2 www.yahoo.com'
# watch -n 10 'dig +short myip.opendns.com @resolver2.opendns.com'


import datetime
import time
from urllib.request import urlopen
from json import load
import os
from os import listdir
from os.path import isfile, join
import random
import tempfile


# the amount to wait between check in Minutes
SleepTime = (1 * 60) / 20  # 3 seconds
SleepTime = (1 * 60) / 12  # 5 seconds
TimeStart = datetime.datetime.now()
NbConnect = 0

# Variable used to store Public IP information and other Stuff
Ip = ""
CB = ""
CC = ""
CCToHide = "FR"
CCPath = os.path.dirname(os.path.realpath(__file__))


# helper used to centralise log method
def log(strline):
    print(formatedtime() + " : " + strline)


# helper to get well Formatted time
# https://stackoverflow.com/questions/415511/how-to-get-current-time-in-python
def formatedtime():
    return time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime())


# get the current public ip
# https://stackoverflow.com/questions/9481419/how-can-i-get-the-public-ip-using-python2-7?noredirect=1&lq=1
def getIp():
    return load(urlopen('http://freegeoip.net/json/'))['ip']


# get the current public country code
# https://stackoverflow.com/questions/9481419/how-can-i-get-the-public-ip-using-python2-7?noredirect=1&lq=1
def getCC():
    return load(urlopen('http://freegeoip.net/json/'))['country_code']


# get the current public country
# https://stackoverflow.com/questions/9481419/how-can-i-get-the-public-ip-using-python2-7?noredirect=1&lq=1
def getpubliccountry():
    return load(urlopen('http://freegeoip.net/json/'))['country_name']


# Update current Public IP information
def getpublicinfo():
    global Ip, CC, CB
    PublicInfo = load(urlopen('http://freegeoip.net/json/'))
    CB = PublicInfo['country_name']
    CC = PublicInfo['country_code']
    Ip = PublicInfo['ip']


# clear the current terminal
def clearscreen():
    os.system('cls' if os.name == 'nt' else 'clear')


# Get Time from start of the srcipt
def getTimeDifferenceFromStart():
    timeDiff = datetime.datetime.now() - TimeStart
    return timeDiff.total_seconds() / 60 / 60


# display info
def displayinfo():
    log("========================================================")
# log("Script start=" + time.strftime("%Y-%m-%d %H:%M:%S", TimeStart))
    log("Current Path=[" + CCPath + "]")
    log("Duration=" + str(round(getTimeDifferenceFromStart(), 4)) + " hours \
       Nb Disconnect=" + str(NbConnect))
    log("Check Interval (seconds)=[" + str(SleepTime) + "]")
    getpublicinfo()
    log("Public Info=[" + CB + "/" + CC + "/" + Ip + "]")
    log("CountryCodeToHide=[" + CCToHide + "]")
    log("========================================================")


# Starting a new OpenVpn Connection
def startconn():
    global NbConnect
    NbConnect = NbConnect + 1
    log("Country Code NOT HIDDEN => Starting an new connection")

    # Determining a random .ovpn of the current directory
    f1 = [f for f in listdir(CCPath) if isfile(join(CCPath, f))]
    f2 = [f for f in f1 if f.lower().endswith(".ovpn")]
    # log("OpenVpn files found : " + str(f2))
    conffile = random.choice(f2)
    log("Using Config File : " + conffile)

    # Using a log file by week
    logfile = "/var/log/openvpn-client-"
    logfile += datetime.datetime.isocalendar(datetime.datetime.now())[0] + "-"
    logfile += datetime.datetime.isocalendar(datetime.datetime.now())[1] + ".log"
    log("LogFile : " + logfile)


# Main start of the script
clearscreen()
log("Script start")

# simple loop that wait for a keystroke interrupt it with
# the usual Ctrl-C (SIGINT).
# https://stackoverflow.com/questions/13180941/how-to-kill-a-while-loop-with-a-keystroke
try:
    while True:
        displayinfo()
        # If the country code is not hidden, restarting the connection
        if CC == CCToHide:
            startconn()

        time.sleep(SleepTime)
        clearscreen()
except KeyboardInterrupt:
    log("")
    log("KeyboardInterrupt sequence received...ending script")
    log("")
    pass

log("Script end")
