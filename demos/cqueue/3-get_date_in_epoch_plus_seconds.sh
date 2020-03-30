#!/bin/sh

seconds=$1

ct=`date`
echo "Current time: $ct"
cte=`date --date="$ct" +%s`
echo "Current timestamp since epoch: $cte"
cteplus=$((cte + seconds))
echo "Adding $seconds to timestamp: $cteplus"

