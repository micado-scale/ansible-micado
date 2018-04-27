#!/bin/bash

#
# stop apt-daily.service as it locks apt db after the VM becomes available
#
systemctl stop apt-daily.timer
systemctl stop apt-daily.service
systemctl kill --kill-who=all apt-daily.service

# wait until `apt-get updated` has been killed
while ! (systemctl list-units --all apt-daily.service | fgrep -q dead)
do
  sleep 1;
done

# wait until apt.systemd.daily process exists
while (ps aux | grep -q "/apt.systemd.daily instal[l]")
do
  sleep 1;
done
