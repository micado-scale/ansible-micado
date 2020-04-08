#!/bin/sh

settings_file="./_settings"
DL=$1
. $settings_file

if [ -z "$MICADO_MASTER" ]; then
  echo "Please, set MICADO_MASTER in file named \"$settings_file\"!"
  exit
fi

if [ -z "$SSL_USER" ]; then
  echo " Please, set SSL_USER in file named \"$settings_file\"!"
  exit
fi

if [ -z "$SSL_PASS" ]; then
  echo " Please, set SSL_PASS in file named \"$settings_file\"!"
  exit
fi

if [ -z "$APP_ID" ]; then
  echo "Please, set APP_ID in file named \"$settings_file\"!"
  exit
fi

if [ -z "$DL" ]; then
  echo "Please add an argument to the script specifying the deadline in seconds from epoch"
  exit
fi

sed "s/DEADLINE: [0-9]*/DEADLINE: $DL/" cqueue.yaml > cqueue.tmp.yaml

echo "Updating \"$APP_ID\" on MiCADO at $MICADO_MASTER..."
curl --insecure -s -F file=@"cqueue.tmp.yaml" -X PUT -u "$SSL_USER":"$SSL_PASS" https://$MICADO_MASTER:$MICADO_PORT/toscasubmitter/v1.0/app/update/$APP_ID | jq
rm cqueue.tmp.yaml