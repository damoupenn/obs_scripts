#! /bin/bash

FILENAME='/home/obs/trigger/trigger.txt'
EMAIL='teampaper.gridsub@gmail.com'
NCORR=35
RAM=8G

ARXIVDIR=/home/obs/grid_output

while :
do
    if [ -f $FILENAME ]
    then
        echo "trigger ${FILENAME} detected, waiting for transfer to complete."
        sleep 1
        tstart=`date -u`
        ustart=`date -u "+%F_%H.%M.%S"`
        THISDIR=${ustart}
        mkdir $ARXIVDIR/$THISDIR
        echo; echo "Moving trigger $FILENAME to archive $ARXIVDIR/$NEWDIR/TX.txt"; echo
        mv $FILENAME $ARXIVDIR/$THISDIR/TX.txt
        
        echo; echo "Beginning Compression on $tstart"; echo
        echo 'Submitting to the queue'
        python submit_to_grid.py -M $EMAIL -t $NCORR -l $RAM -o $ARXIVDIR/$THISDIR $ARXIVDIR/$THISDIR/TX.txt
        #echo "batch_data_redux.sh $ARXIVDIR/$THISDIR/TX.txt" | qsub -t 1:${NCORR} -o $ARXIVDIR/$THISDIR -e $ARXIVDIR/$THISDIR 
        tend=`date -u`
        echo;echo "Compression Submitted to the queue on $tend"

        echo "DONE... for now";echo
    fi
done
