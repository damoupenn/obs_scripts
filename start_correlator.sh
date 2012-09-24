#!/usr/bin/env bash

LOGFILE=/home/obs/logs/start_correlator.log

#source ~/.bashrc
cd /home/obs
echo 'powering on roachs'
bash /home/obs/bin/r_start_64.sh 
echo 'waiting for roach boot to finish'
sleep 40
echo 'running corr_init.py without reinitializing the ibobs'
/usr/bin/python /usr/local/bin/corr_init.py -o  ~/psa32.conf

sleep 5


/usr/bin/python /usr/local/bin/corr_init.py -o ~/psa32.conf 
#while [ !$!='done' ]; do
#        !$
#        /usr/bin/python /usr/local/bin/corr_init.py -o -i ~/ral32.conf
#done

echo 'starting tx scripts' 
bash /home/obs/bin/r_TXallstart.sh 

sleep 5
echo 'running cn_rx.py logging in /home/obs/cn_rx.log'
cd $1
/usr/bin/python /usr/local/bin/cn_rx.py ~/psa32.conf >> ~/logs/cn_rx.log  2>> ~/logs/cn_rx_err.log

