#! /bin/bash

#usage
# send_data_to_still.sh <local path to data>
#
# ex
# send_data_to_still.sh /data/

HOME=/home/obs/
LOGFILE=${HOME}/logs/send_data_to_still_log.txt
OBSDIR=$*
#send odd days to pot1 even days to pot0
DAYNUM=`date -u "+%j"`
POTNUM=`python -c "print ${DAYNUM}%2"`

echo This is send_data_to_still.sh  >> ${LOGFILE}
#start the logging
bwm-ng -t 1000 -o csv -I eth1 >> logs/stillbwlog.txt &
BWMPID=$!

echo Sending data to distller: pot${POTNUM} > ${HOME}/logs/stillrsync.txt
#first send the data
rsync -avuP ${OBSDIR}/z*uv pot${POTNUM}:/data${POTNUM}/ | tee -a ${LOGFILE} | tail -n 2 >> ${HOME}/logs/stillrsync.txt 
#now do the checksum to test
rsync -avuP ${OBSDIR}/z*uv pot${POTNUM}:/data${POTNUM}/ | tee -a ${LOGFILE} | tail -n 2 >> ${HOME}/logs/stillrsync.txt
XFERSTATUS=$?

echo DONE MOVING
#if the rsync checksums ok, run a daily move. otherwise send an email?
if [ $XFERSTATUS -eq 0 ]
then
    echo sending distillation trigger >> ${LOGFILE}
    date >> ${LOGFILE}
    cd ${OBSDIR}
    echo `pwd` ?????
    echo `ls -d -1 z*uv | sed "s/^/\/data${POTNUM}\//"`> trigger.txt
    echo scp trigger.txt still1:trigger/ >> ${LOGFILE}
    scp trigger.txt still1:trigger/trigger.txt >> ${LOGFILE}
    cd -

    echo slotting data into a nightly directory
    ${HOME}/bin/daily_move.py ${OBSDIR}/z*uv >> ${LOGFILE}

    NEWDIR=`ls -tr ${OBSDIR}/ | grep ^psa |tail -n1`
    echo Moved data to ${NEWDIR} and marked for deletion in nextdelete.txt >> ${LOGFILE}
    echo ${NEWDIR} >> nextdelete.txt

else
    echo the move has failed!!!
    #the move has failed!!
    #do something!!!
fi

#clean up   
#kill $BWMPID



