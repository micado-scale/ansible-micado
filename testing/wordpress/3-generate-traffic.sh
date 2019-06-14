#!/bin/sh

settings_file="./_settings"

. $settings_file

if [ -z "$MICADO_MASTER" ]; then
  echo "Please, set MICADO_MASTER in file named \"$settings_file\"!"
  exit
fi

if [ -z "$MICADO_WORKER" ]; then
  MICADO_WORKER=$MICADO_MASTER
  echo "No MICADO_WORKER specified, trying MICADO MASTER - ensure port 30010 is open..."
fi

if [ -z "$SSL_USER" ]; then
  echo " Please, set SSL_USER in file named \"$settings_file\"!"
  exit
fi

if [ -z "$SSL_PASS" ]; then
  echo " Please, set SSL_PASS in file named \"$settings_file\"!"
  exit
fi

echo "Small HTTP load test for 10 minutes at $MICADO_WORKER:30010... CTRL-C to stop"
wrk -t1 -c1 -d10m http://$MICADO_WORKER:30010
# if necessary, adjust the line above to increase the load test
# e.g. wrk -t4 -c40 -d10m http://$MICADO_WORKER:30010
