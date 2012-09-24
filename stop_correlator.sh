#!/usr/bin/env bash
source ~/.bashrc
echo 'killing cn_rx.py'
var1=`pgrep -f cn_rx.py*`
kill -2 $@ $var1 
echo 'killed cn_rx'}
sleep 3

echo 'stopping tx' 
bash /home/obs/bin/r_TXallstop.sh 
echo 'shutting down roachs' 
bash /home/obs/bin/r_stop_64.sh 
