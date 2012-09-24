#! /bin/bash

#$ -S /bin/bash
#$ -N TestRead
#$ -cwd
#$ -j y
#$ -o /home/obs/grid_output

python ReadTriggerFile.py /home/obs/trigger/trigger.txt
