import ue9
from time import time,sleep

ipAddress = '192.168.216.104'

d = ue9.UE9(ethernet=True,ipAddress=ipAddress)

def V2K(V): return V*100.
def get_jd(): return ( time() / 86400.) + 2440587.5 
def get_temps():
	_T = []
	_T.append(str(d.getTemperature()))
	Tb = 0.
	for i in (2,3):
		Tb += 0.5 * V2K(d.readRegister(i))
	_T.append(str(Tb))
	return '\t'.join(_T)
def get_Tstring():
	return '%s\t%s'%(get_jd(),get_temps())

#Define Sampling and writing rates.

SperSamp = 0.1 #Seconds per sample
SperInt  = 10  #Seconds per integration
MperFile = 60   #Minutes per file

OutDir = '/home/obs/output_data/TemperatureData' 

#Write the files.

NperFile = int( 60.* MperFile / SperInt )
NperInt = int(SperInt / SperSamp)
while True:
	Filename = '%s/temp.%s.txt'%(OutDir,str(get_jd()))
	print 'Writing to %s'%Filename
	f = open(Filename,'w')
	i_int = 0
	while i_int < NperFile:
		i_samp = 0
		jd,t1,t2 = 0.,0.,0.
		while i_samp < NperInt:
			_jd,_t1,_t2 = get_Tstring().split('\t')
			sleep(SperSamp)
			jd += float(_jd)/float(NperInt)
			t1 += float(_t1)/float(NperInt)
			t2 += float(_t2)/float(NperInt)
			i_samp += 1
		Tstr = '%f\t%f\t%f\n'%(jd,t1,t2)
		f.write(Tstr)
		i_int += 1
	f.close()
