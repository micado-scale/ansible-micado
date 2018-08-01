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

echo "Deleting cqworker app in MiCADO at $MICADO_MASTER with appid \"$APP_ID\"..."
curl -X DELETE http://$MICADO_MASTER:5050/v1.0/app/undeploy/$APP_ID
