#!/usr/bin/env python
"""
Move all data in the specified directory into daily subdirectories. Day defined as the round JD. This is fine for SA GMT+2 and GB GMT-4
Assumes filenames of the type
<prefix>.2455900.154677.<postfix>

The files:
zen.2455899.1234.uv
zen.2455900.5745.uv

Will go to 
psa899/zen.2455899.1234.uv
psa900/zen.2455900.5745.uv

usage:
daily_move.py /path/to/data/z*uv

"""
DEBUG = False

import sys,glob as gl,os,shutil

rootdir = '/home/obs/'

L_prefix = os.path.join(rootdir,'current_disk/data/psa')
P0_prefix = os.path.join(rootdir,'data0/psa')
P1_prefix = os.path.join(rootdir,'data1/psa')

#find files
allfiles = sys.argv[1:]
JDs = [name.split('.')[1] for name in allfiles]
tJDs = [name.split('.')[1][-4:] for name in allfiles] #tJD = truncated Julian Date
L_paths = dict(zip(allfiles,[L_prefix+tJD for tJD in tJDs]))
P0paths = dict(zip(allfiles,[P0_prefix+tJD for tJD in tJDs]))
P1paths = dict(zip(allfiles,[P1_prefix+tJD for tJD in tJDs]))

unique_tJDs = set(tJDs)
mkdirs = dict(zip(unique_tJDs,[L_prefix+unique_tJD for unique_tJD in unique_tJDs]))
if DEBUG: print "creating directories"
#make the target directories
for tJD in unique_tJDs:
    print mkdirs[tJD],'..',
    if not os.path.exists(mkdirs[tJD]):
	    os.mkdir(mkdirs[tJD])
	    if DEBUG: print "[created]"
    else: 
        if DEBUG:print '[exists]'
if DEBUG: print "I would have moved the following %d files"%(len(allfiles))

for FILE in P0paths:
    newpath = os.path.join(P0paths[FILE], os.path.basename(FILE))
    if os.path.exists(P0paths[FILE]): 
        print 'copying to:',newpath
        if not DEBUG: 
            os.system('cp -r %s %s' %(FILE,newpath))

for FILE in P1paths:
    newpath = os.path.join(P1paths[FILE], os.path.basename(FILE))
    if os.path.exists(P1paths[FILE]): 
        print 'copying to:',newpath
        if not DEBUG: 
            os.system('cp -r %s %s' %(FILE,newpath))

for FILE in L_paths:
    print 'moving to:',os.path.join(L_paths[FILE],os.path.basename(FILE))
    if not DEBUG: 
        os.system('mv %s %s'%(FILE,L_paths[FILE]))
