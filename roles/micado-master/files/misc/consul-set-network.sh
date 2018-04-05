#!/bin/bash
echo "Setup NETWORK starts."
myhost=`hostname`
ipaddress=`ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127.0.0.1 | head -n 1`
cp /etc/hosts /etc/hosts.old
grep -v "$myhost" /etc/hosts.old > /etc/hosts

echo "IPADDRESS: $ipaddress"
echo "$ipaddress $myhost" >> /etc/hosts

rm -rf /etc/resolvconf/*
echo "Setup NETWORK finished."
