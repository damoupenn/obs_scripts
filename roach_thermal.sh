#!/bin/bash

set -o pipefail

function xport_stats() {
  echo -ne '1\nq' | roach_monitor.py ${1} 2>/dev/null | awk '
    /deg C/ {printf " %.2f", $5}
    /Fan/   {printf " %d", $3}
    END     {print " xport"}
  '
}

function sensors_stats() {
  ssh root@${1} 2>/dev/null <<'EOF'
  sensors | awk '
    /Temp/ {printf " %.2f", $4}
    /Fan/  {fan=fan sprintf(" %d", $3)}
    END    {print fan, 0}
  ' && \
  awk '{print $1}' /proc/uptime
EOF
}

date

for r in "${@}"
do
## For some not-yet-understood reason, querying the XPORTs too much can cause
## the ROACHes to go into a bad state.  DO NOT QUERY XPORTs OFTEN IF AT ALL!!
#  if ! stats=$(xport_stats ${r}x)
#  then
    if stats=$(sensors_stats ${r})
    then
      echo $r $stats
    fi
#  fi

done
