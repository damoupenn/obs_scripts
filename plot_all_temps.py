#! /usr/bin/env python
import numpy as np
import sys,os,optparse
from time import time
import matplotlib
matplotlib.use('Agg')
from pylab import *

o = optparse.OptionParser()
o.add_option('-n','--ndays',type=int,default=5,help='Number of days to plot')
o.add_option('-o','--outfile',default='temps.png',help='Destination of figure')
opts,args = o.parse_args(sys.argv[1:])

jd = (time() / 86400.) + 2440587.5
Files2Read = []
for File in args:
	jdF = float('.'.join(File.split('.')[-3:-2]))
	if jd - jdF <= opts.ndays: Files2Read.append(File)

JD,Tin,Tout = [],[],[]
for File in Files2Read:
	print 'Reading',File
	d = np.loadtxt(File)
	for i in range(d.shape[0]):
		JD.append(d[i,0])
		Tin.append(d[i,1])
		Tout.append(d[i,2])

JD = np.array(JD)
JD0 = np.floor(JD[0])
JD -= JD0

figure()
plot(JD,Tin,label='LabJack')
plot(JD,Tout,label='Balun')
ylabel('Temperature [K]')
xlabel('Days since JD %d'%int(JD0))
legend(loc='lower left')
savefig(opts.outfile,fmt='png')
