#! /usr/bin/env python 

#CAUTION: This script only works for 'normal operation'

import os,sys,optparse

o = optparse.OptionParser()
opts,args = o.parse_args(sys.argv[1:])

def JDfromFile(FileName):
    return float('.'.join(FileName.split('.')[-3:-1]))

MetaD = {}
MetaD['files'] = len(args)
JDmax,JDmin = 1e-10,1e10
for File in args:
    _JD = JDfromFile(File)
    JDmax = max(JDmax,_JD)
    JDmin = min(JDmin,_JD)
MetaD['hours'] = (JDmax - JDmin)*24.
MetaD['days'] = 1.

prefix = '/home/obs/MetaData/N'
suffix = '.eor'

for D in MetaD:
    filepath = prefix+D+suffix
    print filepath
    f = open(filepath,'r')
    fileD = f.read()
    try:
        if fileD.endswith('\n'): fileD = fileD[:-1]
        fileD = float(fileD)
        fileD += MetaD[D]
    except(IOError,ValueError): 
        print 'Error:',f.read()
        fileD = MetaD[D]
    f.close()
    os.system('echo "%f" > %s' % (fileD,filepath))
