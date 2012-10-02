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

#make relevant paths
rootdir = sys.argv[-1]
if rootdir[-1]==os.path.sep: rootdir = rootdir[:-1]
rootdir = os.path.dirname(rootdir)

prefix = 'psa'
dir_prefix = os.path.join(rootdir,prefix)

#find files
allfiles = sys.argv[1:]
JDs = [name.split('.')[1] for name in allfiles]
tJDs = [name.split('.')[1][-4:] for name in allfiles] #tJD = truncated Julian Date
paths = dict(zip(allfiles,[dir_prefix+tJD for tJD in tJDs]))

unique_tJDs = set(tJDs)
mkdirs = dict(zip(unique_tJDs,[dir_prefix+unique_tJD+'/' for unique_tJD in unique_tJDs]))
if DEBUG: print "creating directories"
#make the target directories
for tJD in unique_tJDs:
    print mkdirs[tJD],'..',
    if not os.path.exists(mkdirs[tJD]):
	    os.mkdir(mkdirs[tJD])
	    if DEBUG: print "[created]"
    else: 
        if DEBUG:print '[exists]'
if DEBUG: "I would have moved the following %d files"%(len(allfiles))
for FILE in paths:
    print os.path.join(paths[FILE],os.path.basename(FILE))
    if not DEBUG: shutil.move(FILE,paths[FILE])
