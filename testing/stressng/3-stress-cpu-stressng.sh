#!/bin/sh

settings_file="./_settings"

. $settings_file
CPU=$1

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

if [ -z "$CPU" ] || [ "$CPU" -le 0 ] || [ "$CPU" -gt 100 ]; then
  echo "Please add an argument to the script which is between 1-100"
  exit
fi

cp stressng.yaml stressng.tmp.yaml
sed "s/pi -l [0-9]*/pi -l $CPU/" stressng.yaml > stressng.tmp.yaml

echo "Stressing \"$APP_ID\" on MiCADO at $MICADO_MASTER... to a CPU load of $CPU"
curl --insecure -s -F file=@"stressng.tmp.yaml" -X PUT -u "$SSL_USER":"$SSL_PASS" https://$MICADO_MASTER:$MICADO_PORT/toscasubmitter/v1.0/app/update/file/$APP_ID | jq

rm stressng.tmp.yaml
