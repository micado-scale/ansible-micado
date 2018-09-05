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

echo "Updating app with id \"$APP_ID\" using stressng-update.yaml on MiCADO at $MICADO_MASTER..."
curl -F file=@"stressng-update.yaml" -X PUT http://$MICADO_MASTER:5050/v1.0/app/update/file/$APP_ID
