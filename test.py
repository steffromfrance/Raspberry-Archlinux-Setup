# Simple Script to start and monitor an  OpenVpn Connection using Python 3.x

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


# Update current Public IP information using IP Stack
def getpublicinfofrompersofree():
    global Ip, CC, CB, NbLostDns
    with urllib.request.urlopen("http://stef2018.free.fr/monitoring/getpublicip.php") as url:
            print(url)
            
            
            
getpublicinfofrompersofree()

