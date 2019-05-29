#!/bin/sh

settings_file="./_settings"
. $settings_file

if [ -z "$CQUEUE_SERVER_IP" ]; then
  echo "Please, set CQUEUE_SERVER_IP in file named \"$settings_file\"!"
  exit
fi
JOBID=$1
if [ -z "$JOBID" ]; then
  echo "Please, set JOBID as argument!" 
  exit
fi

echo "Querying stdout of job: \"$JOBID\" from CQueue at $CQUEUE_SERVER_IP ..."
curl -X GET http://$CQUEUE_SERVER_IP:30888/task/$JOBID/result
echo
