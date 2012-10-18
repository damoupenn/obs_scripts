#$ -S /bin/bash
#$ -V
#$ -j y
#$ -l h_vmem=8G
#$ -N Bootleg 
#$ -cwd

ARGS=`ReadTriggerFile.py $*`
echo data_redux.sh $ARGS
STARTPATH=`pwd`
ENDPATH=/home/obs/output_data
SCRATCH=/home/obs/scratch

for FILE in $ARGS; do
    echo --------------------
    echo --- Working on $FILE ---
    # Only process this file if the end product is missing
    if ls ${FILE}cRRE &> /dev/null; then
        echo ${FILE}cRRE exists.  Skipping...
        continue
    fi
    FILEBASE=`python -c "import os; print os.path.basename('$FILE')"`
    echo $FILEBASE
    # Copy files to a local directory for fast access
    echo get_uv_neighbor.py $FILE returns `get_uv_neighbor.py $FILE`
    for TFILE in `get_uv_neighbor.py $FILE`; do
        TFILEBASE=`python -c "import os; print os.path.basename('$TFILE')"`
        # If the uvcR file is here already, don't bother
        if ls ${SCRATCH}/${TFILEBASE}cR &> /dev/null; then
            echo Using ${SCRATCH}/${TFILEBASE}cR
            continue
        fi
        echo Generating ${SCRATCH}/${TFILEBASE}cR
        echo cp -r $TFILE ${SCRATCH}/${TFILEBASE}
        time cp -r $TFILE ${SCRATCH}/${TFILEBASE}
        echo correct_psa898.py ${SCRATCH}/$TFILEBASE
        time correct_psa898.py ${SCRATCH}/$TFILEBASE
        #time correct_psa128.py ${SCRATCH}/$TFILEBASE
        echo rm -rf ${SCRATCH}/${TFILEBASE}
        time rm -rf ${SCRATCH}/${TFILEBASE}
        echo xrfi_simple.py -a 1 --combine -t 20 -c 0_130,755_777,1540,1704,1827,1868,1885_2047 --df=6 ${SCRATCH}/${TFILEBASE}c
        time xrfi_simple.py -a 1 --combine -t 20 -c 0_130,755_777,1540,1704,1827,1868,1885_2047 --df=6 ${SCRATCH}/${TFILEBASE}c
        echo rm -rf ${SCRATCH}/${TFILEBASE}c
        time rm -rf ${SCRATCH}/${TFILEBASE}c
        echo
    done
    echo cd ${SCRATCH}
    cd ${SCRATCH}
    echo data_redux.sh ${FILEBASE}cR
    data_redux.sh ${FILEBASE}cR
    echo cd $STARTPATH
    cd $STARTPATH
    echo cp -r ${SCRATCH}/${FILEBASE}cRR[DEF] ${ENDPATH}/
    time cp -r ${SCRATCH}/${FILEBASE}cRR[DEF] ${ENDPATH}/ 
    echo cp ${SCRATCH}/${FILEBASE}cRE.npz ${ENDPATH}/
    time cp ${SCRATCH}/${FILEBASE}cRE.npz ${ENDPATH}/
    time rm -rf ${SCRATCH}/${TFILEBASE}cRR
done

# Final clean-up

# time exec_daily_move.sh

for FILE in $ARGS; do
    for TFILE in `get_uv_neighbor.py $FILE`; do
        FILEBASE=`python -c "import os; print os.path.basename('$TFILE')"`
        echo rm -rf ${SCRATCH}/${FILEBASE}*
        time rm -rf ${SCRATCH}/${FILEBASE}*
        ssh -q -o ConnectTimeout=3 pot0 "python /home/obs/daily_move_pot0.py /data0/${FILEBASE}"
        ssh -q -o ConnectTimeout=3 pot1 "python /home/obs/daily_move_pot1.py /data1/${FILEBASE}"
        ssh -q -o ConnectTimeout=3 still2 "python /home/obs/Distillation/daily_move.py ${ENDPATH}/${FILEBASE}cRR[DEF]"
        ssh -q -o ConnectTimeout=3 still2 "python /home/obs/Distillation/daily_move.py ${ENDPATH}/${FILEBASE}cRE.npz"
    done
done


echo DONE
