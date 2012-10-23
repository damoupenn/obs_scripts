#! /usr/bin/env python 

import sys,optparse
import matplotlib
matplotlib.use('Agg')
from pylab import *

o = optparse.OptionParser()
o.add_option('-o','--outfile',dest='outfile',default='today.png',help='Path to the output image file')
opts,files = o.parse_args(sys.argv[1:])

output_file = files[0]

#plot pid vs time
T={}
T['real'] = []
T['user']  = []
T['sys']  = []

lines = open(output_file).readlines()

def fmt_times(tstr):
    try:
        s1,s2 = tstr.split('m')
        s1 = float(s1)
        s2 = float(s2[:-2])/60.
        return s1 + s2
    except(ValueError): return 0.

for L in lines:
    for key in T.keys():
        if L.find(key) != -1: 
            T[key].append(fmt_times(L.split('\t')[-1]))

CumT = {}
figure(0)
for key in T:
    subplot(221)
    plot(T[key],label=key)
    xlim([0,len(T[key])])
    xticks([])
    CumT = []
    for i,t in enumerate(T[key]): CumT.append(np.sum(T[key][:i]))
    print key,CumT[-1]
    subplot(223)
    plot(CumT,label=key)
    xlim([0,len(T[key])])
    xlabel('Process number')
legend(loc='upper left')

#plot N_bl vs memory usage

lines = open(output_file).readlines()
m = []
for L in lines:
    if L.find('VmSize') != -1: m.append(float(L.split(' ')[-2]))
m = np.array(m)

kb2Gb = 2**20

subplot(222)
plot(m/kb2Gb)
xticks([])
subplot(224)
plot(np.diff(m)/kb2Gb)

subplots_adjust(hspace=0)
savefig(opts.outfile,fmt='png')
