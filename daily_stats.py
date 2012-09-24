#!/usr/bin/env python
"""
Send an email to paperstats.blogger.com filled with lovely, lovely information.
"""

import sys,os,statvfs,aipy as a
from glob import glob
import smtplib
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from time import time

msg = MIMEMultipart()


To = "teampaper.stats@blogger.com"
#To = "wheresmytab@gmail.com"
From = "teampaper@gmail.com"


def percent(stat):
    return 100. - 100.*float(stat[statvfs.F_BAVAIL])/float(stat[statvfs.F_BLOCKS])

def print_df():
    disks = glob('/mnt/psa*')
    string = ''
    for i,disk in enumerate(disks):
        fstring = '%s is %2.1d percent full. \n' % (disk, percent(os.statvfs(disk)))
        string += fstring
    return string

# Find Julian Date
U = time()
s = U % 60
aux = (U-s) / 60
m = aux % 60
aux = (aux-m) / 60
h = aux % 24
days = (aux-h) / 24
JD = (U/86400.0)+2440587.5


#!!!!path_imag = 
#imag = open(path_imag, 'rb')
#msg_imag = MIMEImage(imag.read())
#imag.close()
#outer.attach(msg_imag)

# Get system stats
#move_file(sys.argv[-1])
move_ok_str = 'Data moved successfully'
#disk_usage_str = print_df()
disk_usage_str = ''.join(os.popen('df -h| grep /mnt').readlines())

msg['Subject'] =  'PSA obs report for JD: '+str(int(JD)) #str(JD)+' update'
msg['To'] = To
msg['From'] = From
Body = "Disk Usage:\n"
Body += disk_usage_str+"\n\n"
#Body += "daily_move.py status: \t\t" + "[Unavailable]"+'\n'
Body += "rsync to shredder status: \t\t" + '\n'
rsync_status = ''.join(open('/home/obs/logs/rsynclog.txt').readlines())
Body += rsync_status
Body += '\n'
#Body += "Peak Balun Temp: \t\t" + "[Unavailble]"+'\n'

aa = a.phs.ArrayLocation(('-30:43:17.5', '21:25:41.9')) # Karoo, ZAR, GPS. #elevation=1085m
aa.set_jultime(int(JD)+2/24.+0.5)
Body += "Midnight LST:\t" + str(aa.sidereal_time())+'\n'
Body += "-----------\n"
Body += "last cn_rx.py entry (via screen)\n"
Body += open('/home/obs/last_cn_rx.log').read()
Body += '\n\n'
msg.attach(MIMEText(Body))
#Header = m = "From: %s\r\nTo: %s\r\nSubject: %s\r\nX-Mailer: My-Mail\r\n\r\n" % (From, To, 'PSA obs report for JD: '+str(int(JD)))
#
#Message = """
#
#%s
#
#"""%(Body)

#attach temp plot
msg.attach(MIMEImage(open('/home/obs/Temperature_Logs/all_temps.png').read()))

print "sending email"
print Body
username = 'teampaper'
password = 'b00lardy'

# Send email
server = smtplib.SMTP('smtp.gmail.com:587')
server.starttls()
server.login(username,password)
server.sendmail(From, [To], msg.as_string())
server.quit()

print "email sent"
