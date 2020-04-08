#!/bin/sh

settings_file="./_settings"
. $settings_file

if [ -z "$CQUEUE_SERVER_IP" ]; then
  echo "Please, set CQUEUE_SERVER_IP in file named \"$settings_file\"!"
  exit
fi
NUM=$1
if [ -z "$NUM" ]; then
  echo "Please, set number of jobs to submit as argument!"
  exit
fi

echo "Submitting $NUM items to CQueue at $CQUEUE_SERVER_IP ..."
for i in `seq $NUM`; do curl -H 'Content-Type: application/json' -X POST -d'{"image":"ubuntu", "cmd":["/bin/sh", "-c", "echo Hello World! Sleeping...;sleep 30;echo finished."]}' http://$CQUEUE_SERVER_IP:30888/task; done
echo
