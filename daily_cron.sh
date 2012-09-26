#!/bin/bash

HOME=/home/obs/
OBS_DIR=/data/psa6192/
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

#MONITOR_FILES=`${HOME}/bin/lst_select.py -s ${MONITOR_SRCS} ${OBS_DIR}/z*uv -C ${CALFILE}`
#echo Monitoring files: ${MONITOR_FILES} >> ${LOGFILE}
#
#echo ---- >> ${LOGFILE}
#echo ${HOME}/bin/pull_gridspacing.py --correct ${MONITOR_FILES} >> ${LOGFILE}
#${HOME}/bin/pull_gridspacing.py --correct ${MONITOR_FILES} >> ${LOGFILE}
#echo finished making reduced data set at `date` >>${LOGFILE}
#
#
#
#echo ---->> ${LOGFILE}
#echo moving data to shredder:/data3/paper/psa/psalive/ >>${LOGFILE}
#date >> ${LOGFILE}
#rsync -avz ${OBS_DIR}/z*G shredder:/data3/paper/psa/psalive/ |tee -a ${LOGFILE} | tail -n 2 > ${HOME}/logs/rsynclog.txt
#date >> ${LOGFILE}
#echo total amount on shredder: `ssh shredder du -csh /data3/paper/psa/psalive/z*G | tail -n 1` >> ${HOME}/logs/rsynclog.txt
#
#echo ---- >> ${LOGFILE}
#echo ${HOME}/bin/daily_move.py ${OBS_DIR}/z*uvG >> ${LOGFILE}
#${HOME}/bin/daily_move.py ${OBS_DIR}/z*uvG >> ${LOGFILE}




#echo ---- >>${LOGFILE}
#echo ${HOME}/bin/daily_move.py ${OBS_DIR}/z*uv >>${LOGFILE}
#${HOME}/bin/daily_move.py ${OBS_DIR}/z*uv >>${LOGFILE}


#send odd days to pot1 even days to pot0
DAYNUM=`date -u "+%j"`
POTNUM=`python -c "print ${DAYNUM}%2"`
echo Sending data to distller: pot${POTNUM} > ${HOME}/logs/stillrsync.txt
NSTREAMS=3
echo Using $NSTREAMS rsync channels
WAITSTREAMPIDS=
for STREAM in `python -c "print ' '.join(map(str,range(1,${NSTREAMS}+1)))"`
do
    echo starting data stream $STREAM
    STREAMFILES=`pull_args.py -t1:${NSTREAMS} --taskid=${STREAM} ${OBS_DIR}/z*uv`
    echo streaming `echo $STREAMFILES | wc -w` files
    echo $STREAMFILES > ${HOME}/logs/stream${STREAM}.txt
    rsync -avuP ${STREAMFILES} pot${POTNUM}:/data${POTNUM}/ | tee -a ${LOGFILE} | tee -a \
        ${HOME}/logs/stream${STREAM}.txt |tail -n 2 >> ${HOME}/logs/stillrsync.txt &
    WAITSTREAMPIDS="${WAITSTREAMPIDS} "$!
done
#wait for all the streams to finish
wait $WAITSTREAMPIDS
#check that all the files
rsync -avuP ${OBS_DIR}/z*uv pot${POTNUM}:/data${POTNUM}/ | tee -a ${LOGFILE} | tail -n 2 >> ${HOME}/logs/stillrsync.txt 



#if the rsync checksums ok, run a daily move. otherwise send an email?
if [ $? -eq 0 ]
then
    ${HOME}/bin/daily_move.py ${OBS_DIR}/z*uv >> ${LOGFILE}
    NEWDIR=`ls -tr ${OBSDIR}/ | grep ^psa |tail -n1`
    echo Moved data to ${NEWDIR} and marked for deletion in nextdelete.txt >> ${LOGFILE}
    echo ${NEWDIR} >> nextdelete.txt
fi

echo sending distillation trigger >> ${LOGFILE}
date >> ${LOGFILE}
cd ${OBS_DIR}
ls -d -1 z*uv | sed "s/^/\/data${POTNUM}\//" > trigger.txt
echo rsync -a trigger.txt still1:trigger/ >> ${LOGFILE}
rsync -a trigger.txt still1:trigger/ >> ${LOGFILE}
cd -






#send obs report to blogger
if [ 1 -eq 0 ]
then
echo ---- >> ${LOGFILE}
echo python ${HOME}bin/plot_all_temps.py `ls -tr ${TEMPS_DIR}/2*txt | tail -n 100`
python ${HOME}bin/plot_all_temps.py `ls -tr ${TEMPS_DIR}/2*txt | tail -n 100`
cp ${TEMPS_DIR}/all_temps.png ${TEMPS_DIR}/`date +"%F"`_all_temps.png

#NEWDIR=`ls -tr ${OBSDIR}/ | grep ^psa |tail -n1`
#echo Moved data to ${NEWDIR} >> ${LOGFILE}

#send_paper_log (blogger and local)
echo Sending the status email >> ${LOGFILE}
python ${HOME}/bin/daily_stats.py >> ${LOGFILE}
fi
