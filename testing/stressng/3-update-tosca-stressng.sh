#!/bin/sh

settings_file="./_settings"

. $settings_file 

if [ -z "$MICADO_MASTER" ]; then
  echo "Please, set MICADO_MASTER in file named \"$settings_file\"!"
  exit
fi

if [ -z "$SSL_USER" ]; then
  echo " Please, set SSL_USER in file named \"$settings_file\"!"
fi

if [ -z "$SSL_PASS" ]; then
  echo " Please, set SSL_PASS in file named \"$settings_file\"!"
fi

if [ -z "$APP_ID" ]; then
  echo "Please, set APP_ID in file named \"$settings_file\"!"
  exit
fi

echo "Updating app with id \"$APP_ID\" using stressng-update.yaml on MiCADO at $MICADO_MASTER..." 
curl --insecure -s -F file=@"stressng-update.yaml" -X PUT https://$SSL_USER:$SSL_PASS@$MICADO_MASTER:$MICADO_PORT/toscasubmitter/v1.0/app/update/file/$APP_ID | jq
