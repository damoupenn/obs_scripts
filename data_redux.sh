#! /bin/bash

UVCR=$*
for FILE in $UVCR; do
    echo -------------------------------------
    echo Working on $FILE
    echo get_uv_neighbor.py $FILE
    TRIPLET=`get_uv_neighbor.py $FILE`
    TRIP_LEN=`python -c "print len('${TRIPLET}'.split())"`
    if [ $TRIP_LEN -lt 3 ] ; then 
        echo 'triplet is:' $TRIPLET
        echo 'trip_len is:' $TRIP_LEN
        echo No adjacent files to use.  Skipping...
        continue
    fi
    TRIPLETR=`python -c "t = '${TRIPLET}'.split(); print ' '.join([t[0],t[1]+'R',t[2]])"`
    if ! ls ${FILE}R &> /dev/null; then
        echo ${FILE}R not found.  Assuming improved flags need to be generated...
        echo "ddr_filter_coarse.py -a 1 -p xx,xy,yx,yy --clean=1e-3 --maxbl=300 --output=ddr --invert $TRIPLET"
        time ddr_filter_coarse.py -a 1 -p xx,xy,yx,yy --clean=1e-3 --maxbl=300 --output=ddr --invert $TRIPLET
        echo "xrfi_simple.py -a 1 --combine -t 20 -n 4 ${FILE}E --to_npz=${FILE}E.npz"
        time xrfi_simple.py -a 1 --combine -t 20 -n 4 ${FILE}E --to_npz=${FILE}E.npz
        echo "xrfi_simple.py -a all --combine -t 20 ${FILE} --from_npz=${FILE}E.npz"
        time xrfi_simple.py -a all --combine -t 20 ${FILE} --from_npz=${FILE}E.npz
    fi
    if ls ${FILE}R &> /dev/null; then
        echo "ddr_filter_coarse.py -a all -p xx,xy,yx,yy --clean=1e-4 --maxbl=300 --nsections=10 $TRIPLETR"
        time ddr_filter_coarse.py -a all -p xx,xy,yx,yy --clean=1e-4 --maxbl=300 --nsections=10 $TRIPLETR
    fi
done
