#!/bin/bash

#
# This is the runcmd part from cloud-config...
#

#adduser --disabled-password --gecos "" prometheus

#
# contents of /bin/consul-set-network.sh

echo "Setup NETWORK starts."
myhost=`hostname`
ipaddress=`ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127.0.0.1 | head -n 1`
cp /etc/hosts /etc/hosts.old
grep -v "$myhost" /etc/hosts.old > /etc/hosts

echo "IPADDRESS: $ipaddress"
echo "$ipaddress $myhost" >> /etc/hosts

rm -rf /etc/resolvconf/*
echo "Setup NETWORK finished."

# end of contents of /bin/consul-set-network.sh
#

dhclient
oldhostname=$(hostname -s)
new_host_name=master-$(date +%s | sha256sum | base64 | head -c 32 ; echo)
echo $new_host_name > /etc/hostname
hostname -F /etc/hostname
line=127.0.1.1'\t'$new_host_name
sed -i "s/$oldhostname/$new_host_name/g" /etc/hosts
echo $line >> /etc/hosts
export DEBIAN_FRONTEND=noninteractive
dpkg-reconfigure openssh-server
resolvconf -u
echo nameserver 8.8.8.8 >> /etc/resolv.conf

## Start Swarm
docker swarm init --advertise-addr=$IP
docker node update --availability drain $(hostname)

## Insert policykeeper source code as volume in its container (temporary solution)
git clone https://github.com/micado-scale/component-policy-keeper.git /var/lib/micado/policykeeper/src

export IP=$(hostname -I | cut -d\  -f1)
docker-compose -f /var/lib/micado/docker-compose.yml up -d
cd /var/lib/micado/tosca-submitter/
python3 api.py
