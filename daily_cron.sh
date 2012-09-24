#!/bin/bash

HOME=/home/obs/
OBS_DIR=/home/obs/datadisk/
TEMPS_DIR=/home/obs/Temperature_Logs/

LOGFILE=${HOME}/logs/cronlog.txt
CALFILE=psa746_v004
MONITOR_SRCS=pic


echo ---------- >>  ${LOGFILE}
echo this is the daily cron log >> ${LOGFILE}
date >> ${LOGFILE}



#SCREENLOG=`ls -tr ${HOME} | grep ^screenlog |tail -n1`
RXLOG=${HOME}/logs/cn_rx.log
echo grab the last integration packet from ${RXLOG} >>${LOGFILE}
echo 'tail -n 23 ${RXLOG} > last_cn_rx.log' >> ${LOGFILE}
tail -n 23 ${RXLOG} > ${HOME}/last_cn_rx.log

#echo ---- >> ${LOGFILE}
#echo python ${HOME}/bin/daily_stats.py
#python ${HOME}/bin/daily_stats.py >> ${LOGFILE}

MONITOR_FILES=`${HOME}/bin/lst_select.py -s ${MONITOR_SRCS} ${OBS_DIR}/z*uv -C ${CALFILE}`
echo Monitoring files: ${MONITOR_FILES} >> ${LOGFILE}

echo ---- >> ${LOGFILE}
echo ${HOME}/bin/pull_gridspacing.py --correct ${MONITOR_FILES} >> ${LOGFILE}
${HOME}/bin/pull_gridspacing.py --correct ${MONITOR_FILES} >> ${LOGFILE}
echo finished making reduced data set at `date` >>${LOGFILE}



echo ---->> ${LOGFILE}
echo moving data to shredder:/data3/paper/psa/psalive/ >>${LOGFILE}
date >> ${LOGFILE}
rsync -avz ${OBS_DIR}/z*G shredder:/data3/paper/psa/psalive/ |tee -a ${LOGFILE} | tail -n 2 > ${HOME}/logs/rsynclog.txt
date >> ${LOGFILE}
echo total amount on shredder: `ssh shredder du -csh /data3/paper/psa/psalive/z*G | tail -n 1` >> ${HOME}/logs/rsynclog.txt

echo ---- >> ${LOGFILE}
echo ${HOME}/bin/daily_move.py ${OBS_DIR}/z*uvG >> ${LOGFILE}
${HOME}/bin/daily_move.py ${OBS_DIR}/z*uvG >> ${LOGFILE}


echo ---- >>${LOGFILE}
echo ${HOME}/bin/daily_move.py ${OBS_DIR}/z*uv >>${LOGFILE}
${HOME}/bin/daily_move.py ${OBS_DIR}/z*uv >>${LOGFILE}

echo ---- >> ${LOGFILE}
echo python ${HOME}bin/plot_all_temps.py `ls -tr ${TEMPS_DIR}/2*txt | tail -n 100`
python ${HOME}bin/plot_all_temps.py `ls -tr ${TEMPS_DIR}/2*txt | tail -n 100`
cp ${TEMPS_DIR}/all_temps.png ${TEMPS_DIR}/`date +"%F"`_all_temps.png

NEWDIR=`ls -tr ${OBSDIR}/ | grep ^psa |tail -n1`
echo Moved data to ${NEWDIR} >> ${LOGFILE}

#send_paper_log (blogger and local)
echo Sending the status email >> ${LOGFILE}
python ${HOME}/bin/daily_stats.py >> ${LOGFILE}
