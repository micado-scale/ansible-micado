#!/bin/sh

settings_file="./_settings"

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

HTTP_PORT=$(curl --insecure -X GET -s -u "$SSL_USER":"$SSL_PASS" https://$MICADO_MASTER:$MICADO_PORT/toscasubmitter/v1.0/list_app | jq ".data[0].outputs.K8sAdaptor.$APP_NAME[0].node_port")

echo -n "Generating 50 requests/minute for 10 minutes at $MICADO_MASTER:$HTTP_PORT... CTRL-C to stop"
i=0
while [ $i -lt 500 ]; do
  curl -s $MICADO_MASTER:$HTTP_PORT > /dev/null
  echo -n "."
  sleep 1
  i=$(($i+1)) 
done
