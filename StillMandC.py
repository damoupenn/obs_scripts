#! /usr/bin/env python
"""
Send an email to paperstats.blogger.com filled with the following information:
    - Summary plot of yesterday's RFI flags
    - Summary of yesterday's data compression
    - Summary of EoR Campaign to date.
    - disk usage.
    - Summary of daily move to shredder.
"""

import sys,os,smtplib
from time import time
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart

msg = MIMEMultipart()

To = "teampaper.stats@blogger.com"
From = "teampaper@gmail.com"

msg['To'] = To
msg['From'] = From

EmailBodyString = ''

def ls_list(path):
    return os.popen('ls -dt %s'%path).readlines()

##############################################
# Find Most Recent Completed Grid Submission #
##############################################

NewData = True
ThisDir,i = False,0
LastQsub = ls_list('/home/obs/grid_output/*')
while(not ThisDir and i <= len(LastQsub)):
    LQ = LastQsub[i][:-1]
    QsubDate = LQ.split('/')[-1]
    Bootlegs = ls_list('%s/Bootleg*'%LQ)
    Done = True
    for B in Bootlegs: Done = Done and  'DONE' in open(B[:-1]).readlines()[-1]
    if not Done:
        EmailBodyString += 'Compression currently running on data from %s'%QsubDate
        i += 1
    else: 
        if os.path.exists('%s/SentToBlog'%LQ): 
            NewData = False
            ThisDir = True
        else: 
            os.system('touch %s/SentToBlog'%LQ)
        LastQsub = LQ
        ThisDir=True

msg['Subject'] = 'Still obs report for Grid Submission dated %s' % QsubDate
print 'Reading data from %s' % LastQsub

#########################
# Summarize Compression #
#########################

if NewData:
    EmailBodyString += '\nCOMPRESSION SUMMARY:\n\n'
    FileList = open(LastQsub+'/TX.txt').readlines()
    FileList.sort()
    args =(len(FileList),os.path.basename(FileList[0][:-1]),os.path.basename(FileList[-1][:-1]))
    EmailBodyString += '%d files in Trigger File, from %s to %s.\n' % args
else:
    EmailBodyString += '\nCOMPRESSION ALREADY REPORTED\n\n'

########################
# Find the Output Data #
########################

def fmt_times(tstr):
    try: 
        s1,s2 = tstr.split('m')
        s1 = float(s1)
        s2 = float(s2[:-2])/60.
        return s1 + s2
    except(ValueError): return 0.

if NewData:
    EmailBodyString += '\nCOMPRESSION TIME AND MEMORY SUMMARY:\n\n'
    OutDir = None
    BootlegFile = ls_list('%s/Bootleg*'%LastQsub)[0][:-1]
    t,Vmem = 0.,0.
    for line in open(BootlegFile).readlines():
        if 'real' in line and not 'imaginary' in line: 
            t += fmt_times(line.split('\t')[-1]) 
        if 'VmSize' in line: 
            Vmem = max(Vmem,float(line.split(' ')[-2]))
        if 'moving to' in line: 
            OutDir = '/'.join((line.split(' ')[-1]).split('/')[:-1])
    if OutDir is None: EmailBodyString += 'Something Went wrong with Transmission\n'
    else:
        OutFiles = ls_list('%s/z*E'%OutDir)
        EmailBodyString += '\t%d files received in %s\n'%(len(OutFiles),OutDir)
        du = os.popen('du -sh %s'%OutDir).readlines()[0].split('\t')[0]
        EmailBodyString += '\t%s of compressed data generated today.\n'%du 
        EmailBodyString += '\tReal time of compression = %3.1f minutes.\n' % t
        Vmem /= 2**20
        EmailBodyString += '\tMaximum memory usage = %2.2f GB per core.\n' % Vmem

        ##################
        # Generate Plots #
        ##################

        RFIcommand = 'python /home/obs/DailyReports/dailyRFIreport.py '
        RFIcommand += ' '.join([ l[:-1] for l in ls_list('%s/*.npz'%OutDir)])
        RFIcommand += ' --outfile=%s/%s' %(LastQsub,'RFIsummary.png') 
        os.system(RFIcommand)

        ##########################
        # Copy data to shredder? #
        ##########################

        t0 = time()
        SENDcommand0 = 'rsync -ruz %s/z*.npz' % OutDir
        SENDcommand0 += ' damo@folio.sas.upenn.edu:/data4/paper/2012EoR/psa_live/%s/'%OutDir.split('/')[-1]
        os.system(SENDcommand0)
        SENDcommand1 = 'rsync -ruz %s/z*RRE' % OutDir
        SENDcommand1 += ' damo@folio.sas.upenn.edu:/data4/paper/2012EoR/psa_live/%s/'%OutDir.split('/')[-1]
        os.system(SENDcommand1)
        t1 = (time()-t0)*60.
        EmailBodyString += 'Data sent to folio: /data4/paper/2012EoR/psa_live/%s\n'%OutDir.split('/')[-1]
        EmailBodyString += 'Transfer took %3.1f minutes.\n'%t1

##########################
# Summarize Eor Campaign #
##########################

EmailBodyString += '\n 2012 EOR CAMPAIGN SUMMARY:\n\n'
if NewData: 
    UPDATEcommand = 'python /home/obs/DailyReports/CampaignStats.py'
    UPDATEcommand += ' %s'%' '.join([l[:-1] for l in ls_list('%s/z*E'%OutDir)])
    os.system(UPDATEcommand)
    for FileName in ls_list('/home/obs/MetaData/*.eor'):
        Fdat = open(FileName[:-1]).read()
        FileDescriptor = os.path.basename(FileName.split('.')[0])[1:]
        EmailBodyString += 'Total %s = %s' %(FileDescriptor,Fdat) 

##################################
# Generate plots of Temperatures #
##################################

TEMPcommand = 'python /home/obs/DailyReports/plot_all_temps.py '
TEMPcommand += ' -o %s/temps.png' % LastQsub
TEMPcommand += ' /home/obs/output_data/TemperatureData/*.txt'
os.system(TEMPcommand)

####################
#Check Lacie Usage.#
####################

LaCies=[]
LaCies.append('/home/obs/current_disk')
LaCies.append('/home/obs/on_deck_disk')
EmailBodyString += '\nDISK USAGE:\n\n'
for disk in LaCies:
    dname = open(disk+'/README').read()
    dname = dname.split('(')[0][:-1]
    EmailBodyString += '\t'+dname+'\n'
    EmailBodyString += '\t'+os.popen('df -h | grep %s'%disk).readlines()[0]+'\n'

msg.attach(MIMEText(EmailBodyString))
if NewData: msg.attach(MIMEImage(open('%s/RFIreport.png'%LastQsub).read()))
msg.attach(MIMEImage(open('%s/temps.png'%LastQsub).read()))

username = 'teampaper'
password = 'b00lardy'

server = smtplib.SMTP('smtp.gmail.com:587')
server.starttls()
server.login(username,password)
server.sendmail(From,[To],msg.as_string())
server.quit()

