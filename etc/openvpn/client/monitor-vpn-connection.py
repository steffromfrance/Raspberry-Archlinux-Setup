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
import urllib.request
import json
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
SleepTime = (1 * 60) / 2  	# 30 seconds
SleepTime = (3 * 60)  		# 3 minutes
TimeStart = datetime.datetime.now()
NbConnect = 0
NbLostDns = 0
SubDir = ''
oPid = 0
ConnectionId = ''
ProfileUsed = ''
IpToHide = ''

# Display a message usage
def getHelp():
    print('')
    print("Start an monitor a existing VPN connection and watch if your public ip is not exposed.")
    print("Usage : monitor-vpn-connection.py IPTOHIDE VPNCONFIG ")
    print("        IPTOHIDE : ip to hide (77.8.99.145, 77., )")
    # print("        VPNTYPE : OPENVPN or PPTP")
    print("        VPNCONFIG : subfolder containing the OPENVPN configuration files (*.ovpn) to use randomly")
    # print("                    -name of the PPTP connection name to use")
    print('')
    exit()

# Variable used to store Public IP information and other Stuff
Ip = ""
CB = ""
CC = ""
# Getting the first parameter representing the Ip to Hide
if(2 <= len(sys.argv)):
    IpToHide = sys.argv[1]
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


# Update current Public IP information using IP Stack
def getpublicinfofromipstack():
    global Ip, CC, CB, NbLostDns
    
    try:
        with urllib.request.urlopen("http://api.ipstack.com/check?access_key=e7f3bebdad486686512b31e9475f31d3&format=1") as url:
            PublicInfo = json.loads(url.read().decode())
            #print(PublicInfo)
        CB = PublicInfo['country_name']
        CC = PublicInfo['country_code']
        Ip = PublicInfo['ip']
        # exit()
    except:
        log("DNS unreachable, connection lost")
        NbLostDns = NbLostDns + 1
        CB = "UNKNOW COUNTRY"
        Ip = IpToHide


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
    # LogFile = "/var/log/openvpn-client-"
    LogFile = CCPath + '/openvpn-client-'
    LogFile += str(datetime.datetime.isocalendar(datetime.datetime.now())[0]) + "-"
    LogFile += str(datetime.datetime.isocalendar(datetime.datetime.now())[1]).zfill(2) + ".log"
    log("LogFile : " + LogFile)
    log("Duration=" + str(round(getTimeDifferenceFromStart(), 4)) + " hours \
       Nb Conn=" + str(NbConnect) + " Nb DNS Lost=" + str(NbLostDns))
    # log("Check Interval (seconds)=[" + str(SleepTime) + "]")
    getpublicinfofromipstack()
    log("Public Info=[" + CB + "/" + CC + "/" + Ip + "]")
    # log("Args : " + print(sys.argv) )
    #log("CountryCodeToHide=[" + CCToHide + "]")
    log("========================================================")


# Starting a new OpenVpn Connection
def startconn():
    global NbConnect, oPid
    NbConnect = NbConnect + 1
    log("My Public Ip NOT HIDDEN => Starting an new connection")

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
    
    #Defining a unique id for the connection
    ConnectionId = ''

    # Defining all the parameters to open the connection
    # Using  SubProcess.Popen function https://docs.python.org/3/library/subprocess.html#subprocess.Popen

    # args2 = ['sudo', 'openvpn', '--daemon', '--script-security ', '2', '--verb', '3', '--mute', '5']
    # args2 = ['/usr/sbin/openvpn', '--daemon', '--script-security ', '2', '--verb', '3', '--mute', '5']
    
    # Defining the openvpn binary to execute depending on the OS
    if os.name == 'nt':
        args2 = ['"C:\\Program Files\\OpenVPN\\bin\\openvpn.exe"']
    else:
        args2 = ['sudo', 'openvpn']
    
    args2.append('--cd')
    args2.append(CCPath)

    args2.append('--verb')
    args2.append('9')
    args2.append('--mute')
    args2.append('5')

    args2.append('--config')
    # args2.append(CCPath + '/' + conffile)
    
    ProfileUsed = CCPath + '/' + conffile
    args2.append(ProfileUsed)

    args2.append('--ca')
    #args2.append(CCPath + '/' + 'ca.crt')
    args2.append('ca.crt')
    args2.append('--tls-auth')
    #args2.append(CCPath + '/' + 'Wdc.key')
    args2.append('Wdc.key')
    args2.append('--auth-user-pass')
    #args2.append(CCPath + '/' + 'auth.txt')
    args2.append('auth.txt')
    # args2.append('--script-security ', '2')
    
    args2.append('--log-append')
    args2.append(LogFile)
    
    args2.append('--daemon')

    # Loggin the command line
    s = " "
    s.join(args2)
    log("Args used to launch OpenVpn : " + s.join(args2))

    oPid = subprocess.Popen(args2)
    log("OpenVpn launched with return code: [" + str(oPid.returncode) + "]")
    # exit()

# Stopping any existing  OpenVpn Connection
def stopconn():
    argskill = ['sudo', 'killall', '-w', 'openvpn']
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
        if Ip.startswith( IpToHide ):
            startconn()
            log("Sleeping " + str(SleepTime / 60) +  " minutes seconds before next check....")
            time.sleep(SleepTime) # Sleeping for x minutes
        else:
           log("My public IP [" + IpToHide + "] is hidden => VPN up an running" )

        time.sleep(SleepTime)
        clearscreen()
except KeyboardInterrupt:
    log("")
    log("KeyboardInterrupt sequence received...ending script")
    log("")
    stopconn()
    pass

log("Script end")
