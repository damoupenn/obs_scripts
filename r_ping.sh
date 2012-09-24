#!/bin/bash

DEFAULT_HOSTS="$(echo px{1..8})"

if [ "${1}" == "-h" -o "${1}" == "--help" ]
then
  echo "Usage: $(basename $0) [HOSTNAME [...]]"
  echo
  echo "Reports up/down status of the specified hosts."
  echo "If no hosts are specified, reports on"
  echo "${DEFAULT_HOSTS}."
  exit 1
fi

HOSTS="${@:-${DEFAULT_HOSTS}}"

for HOST in $HOSTS
do
  if ! ping -c 1 -w 1 $HOST > /dev/null 2>&1
  then
    printf "%-8s DOWN\n" $HOST
  else
    printf "%-8s UP\n" $HOST
  fi
done
