#!/bin/sh

settings_file="./_settings"

. $settings_file 

if [ -z "$MICADO_MASTER" ]; then
  echo "Please, set MICADO_MASTER in file named \"$settings_file\"!"
  exit
fi

if [ -z "$MICADO_PORT" ]; then
  echo "Please, set MICADO_PORT in file named \"$settings_file\"!"
  exit
fi

if [ -z "$APP_ID" ]; then
  echo "Please, set APP_ID in file named \"$settings_file\"!"
  exit
fi

if [ -z "$SSL_USER" ]; then
  echo "Please, set SSL_USER in file named \"$settings_file\"!"
  exit
fi

if [ -z "$SSL_PASS" ]; then
  echo "Please, set SSL_PASS in file named \"$settings_file\"!"
  exit
fi

echo "Submitting cqworker.yaml to MiCADO at $MICADO_MASTER with appid \"$APP_ID\"..." 
curl --insecure -s -F file=@"micado-cqworker.yaml" -F id=$APP_ID -X POST https://$SSL_USER:$SSL_PASS@$MICADO_MASTER:$MICADO_PORT/toscasubmitter/v1.0/app/launch/file/ | jq


