#!/bin/sh

settings_file="./_settings"

. $settings_file

if [ -z "$MICADO_MASTER" ]; then
  echo "Please, set MICADO_MASTER in file named \"$settings_file\"!"
  exit
fi

echo "Retrieving list of running apps from MiCADO at $MICADO_MASTER..."
curl -X GET http://$MICADO_MASTER:5050/v1.0/list_app
