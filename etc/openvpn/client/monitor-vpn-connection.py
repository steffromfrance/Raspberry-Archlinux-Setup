# Simple Script to start and monitor an  OpenVpn Connection using Python 3.x
# Required : Python 3.x (Windows or Linux), openvpn client up and running
# Feel free to Fork, Edit, Optimize....

# Usefull command to check the VPN connection
# watch -n 10 'traceroute -m 2 www.yahoo.com'
# watch -n 10 'dig +short myip.opendns.com @resolver2.opendns.com'

# Manual Laucnh of the VPN connection to test what is wrong
# openvpn --script-security  2 --verb 4 --mute 5 --config /media/HDD1000G/Raspberry-Archlinux-Setup/etc/openvpn/client/cfg2017/Netherlands2-tcp.ovpn --ca /media/HDD1000G/Raspberry-Archlinux-Setup/etc/openvpn/client/cfg2017/ca.crt --tls-auth /media/HDD1000G/Raspberry-Archlinux-Setup/etc/openvpn/client/cfg2017/Wdc.key --auth-user-pass /media/HDD1000G/Raspberry-Archlinux-Setup/etc/openvpn/client/cfg2017/auth.txt
# openvpn  --script-security  2 --verb 4 --mute 5 --config /media/HDD1000G/Raspberry-Archlinux-Setup/etc/openvpn/client/cfg2017/Netherlands1-udp.ovpn --ca /media/HDD1000G/Raspberry-Archlinux-Setup/etc/openvpn/client/cfg2017/ca.crt --tls-auth /media/HDD1000G/Raspberry-Archlinux-Setup/etc/openvpn/client/cfg2017/Wdc.key --auth-user-pass /media/HDD1000G/Raspberry-Archlinux-Setup/etc/openvpn/client/cfg2017/auth.txt 

import datetime
import time
from urllib.request import urlopen
from json import load
import os
from os import listdir
from os.path import isfile, join
import random
# import tempfile
import sys
import subprocess
from pathlib import Path


# the amount to wait between check in Minutes
SleepTime = (1 * 60) / 20  # 3 seconds
SleepTime = (1 * 60) / 12  # 5 seconds
SleepTime = (1 * 60) / 2  # 30 seconds
TimeStart = datetime.datetime.now()
NbConnect = 0
SubDir = ''
oPid = 0


# Display a message usage
def getHelp():
    print('')
    print("Start an monitor a existing VPN connection and watch if your current country is not exposed.")
    print("Usage : monitor-vpn-connection.py COUNTRYCODE VPNTYPE VPNCONFIG ")
    print("        COUNTRYCODE : country code to hide (FR,GB,....)")
    # print("        VPNTYPE : OPENVPN or PPTP")
    print("        VPNCONFIG : depending of the VPNTYPE used")
    print("                    -subfolder containing the OPENVPN configuration files (*.ovpn) to use randomly")
    # print("                    -name of the PPTP connection name to use")
    print('')
    exit()

# Variable used to store Public IP information and other Stuff
Ip = ""
CB = ""
CC = ""
# Getting the first parameter representing the CountryCode to Hide
# or setting it to FR if not defined
if(2 <= len(sys.argv)):
    CCToHide = sys.argv[1]
else:
    getHelp()
if(3 <= len(sys.argv)):
    SubDir = sys.argv[2]
else:
    getHelp()

CCPath = os.path.dirname(os.path.realpath(__file__))
CCPath = os.path.join(CCPath, SubDir)
# LogFile = ""


# helper used to centralise log method
def log(strline: object) -> object:
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
    global LogFile
    log("========================================================")
# log("Script start=" + time.strftime("%Y-%m-%d %H:%M:%S", TimeStart))
    log("Current Path=[" + CCPath + "]")
    # Using a log file by week
    LogFile = "/var/log/openvpn-client-"
    LogFile += str(datetime.datetime.isocalendar(datetime.datetime.now())[0]) + "-"
    LogFile += str(datetime.datetime.isocalendar(datetime.datetime.now())[1]).zfill(2) + ".log"
    log("LogFile : " + LogFile)
    log("Duration=" + str(round(getTimeDifferenceFromStart(), 4)) + " hours \
       Nb Disconnect=" + str(NbConnect))
    log("Check Interval (seconds)=[" + str(SleepTime) + "]")
    getpublicinfo()
    log("Public Info=[" + CB + "/" + CC + "/" + Ip + "]")
    # log("Args : " + print(sys.argv) )
    log("CountryCodeToHide=[" + CCToHide + "]")
    log("========================================================")


# Starting a new OpenVpn Connection
def startconn():
    global NbConnect, oPid
    NbConnect = NbConnect + 1
    log("Country Code NOT HIDDEN => Starting an new connection")

    # Determining a random .ovpn of the current directory
    f1 = [f for f in listdir(CCPath) if isfile(join(CCPath, f))]
    f2 = [f for f in f1 if f.lower().endswith(".ovpn")]
    # log("OpenVpn files found : " + str(f2))
    conffile = random.choice(f2)
    log("Using Config File : " + conffile)

    # Checking if the log file does not exist
    if os.path.isfile(LogFile) == False and False:
        # file does not exist, creating the file with the good user right
        with os.fdopen(os.open(LogFile, os.O_WRONLY | os.O_CREAT, 0o600), 'w') as handle:
            handle.write('Init of the log file')

    # Defining all the parameters to open the connection
    # Using  SubProcess.Popen function https://docs.python.org/3/library/subprocess.html#subprocess.Popen

    # args2 = ['sudo', 'openvpn', '--daemon', '--script-security ', '2', '--verb', '3', '--mute', '5']
    # args2 = ['/usr/sbin/openvpn', '--daemon', '--script-security ', '2', '--verb', '3', '--mute', '5']
    args2 = ['sudo', 'openvpn', '--verb', '4', '--mute', '5']
    # args2.append('--cd')
    # args2.append(CCPath)

    args2.append('--config')
    args2.append(CCPath + '/' + conffile)

    args2.append('--ca')
    args2.append(CCPath + '/' + 'ca.crt')
    args2.append('--tls-auth')
    args2.append(CCPath + '/' + 'Wdc.key')
    args2.append('--auth-user-pass')
    args2.append(CCPath + '/' + 'auth.txt')
    # args2.append('--script-security ', '2')
    args2.append('--log-append')
    args2.append(LogFile)
    # args2.append('--daemon')

    # Loggin the command line
    s = " "
    s.join(args2)
    log("Args used to launch OpenVpn : " + s.join(args2))

    oPid = subprocess.Popen(args2)
    log("OpenVpn launched with return code: [" + str(oPid.returncode) + "]")
    # exit()

# Stopping any existing  OpenVpn Connection
def stopconn():
    argskill = ['sudo', 'killall', 'openvpn']
    oPid = subprocess.Popen(argskill)

# Main start of the script
clearscreen()
log("Script start")

# simple loop that wait for a keystroke interrupt it with
# the usual Ctrl-C (SIGINT).
# https://stackoverflow.com/questions/13180941/how-to-kill-a-while-loop-with-a-keystroke
try:
    stopconn()
    while True:
        displayinfo()
        # If the country code is not hidden, restarting the connection
        if CC == CCToHide:
            startconn()
            log("Sleeping 30 seconds before next check....")
            time.sleep(30) # Sleeping for 30 sec

        time.sleep(SleepTime)
        clearscreen()
except KeyboardInterrupt:
    log("")
    log("KeyboardInterrupt sequence received...ending script")
    log("")
    pass

log("Script end")
