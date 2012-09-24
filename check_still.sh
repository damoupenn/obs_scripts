#! /bin/bash

PREFIXES="1 2 3 4 5 100 101"

for I in $PREFIXES;
do 
ping -c 1 10.0.2.${I}
done
