#!/bin/sh

settings_file="./_settings"

. $settings_file

if [ -z "$MICADO_MASTER" ]; then
  echo "Please, set MICADO_MASTER in file named \"$settings_file\"!"
  exit
fi

if [ -z "$APP_ID" ]; then
  echo "Please, set APP_ID in file named \"$settings_file\"!"
  exit
fi

if [ -z "$SSL_USER" ]; then
  echo " Please, set SSL_USER in file named \"$settings_file\"!"
fi

if [ -z "$SSL_PASS" ]; then
  echo " Please, set SSL_PASS in file named \"$settings_file\"!"
fi

echo "Deleting app with id \"$APP_ID\" from MiCADO at $MICADO_MASTER..."
curl --insecure -X DELETE https://$SSL_USER:$SSL_PASS@$MICADO_MASTER/toscasubmitter/v1.0/app/undeploy/$APP_ID
