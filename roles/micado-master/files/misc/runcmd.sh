#!/bin/bash

#
# disable apt-daily.service as it locks apt db after the VM becomes available
#
systemctl stop apt-daily.timer
systemctl stop apt-daily.service
systemctl kill --kill-who=all apt-daily.service

# wait until `apt-get updated` has been killed
while ! (systemctl list-units --all apt-daily.service | fgrep -q dead)
do
  sleep 1;
done

#
# This is the runcmd part from cloud-config...
#
adduser --disabled-password --gecos "" prometheus
/bin/consul-set-network.sh
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
# Download config files
export GITHUB_URL=https://raw.githubusercontent.com/micado-scale/micado/0.3.x
curl -L $GITHUB_URL/configs/executor_config.sh --create-dirs -o /var/lib/micado/prometheus_executor/config/conf.sh
curl -L $GITHUB_URL/configs/consul_checks.json --create-dirs -o /var/lib/micado/consul/config/checks.json
# Change health check ip address for host ip
sed -i 's/healthcheck_ip_change/'$(hostname -I | cut -d\  -f1)'/g' /var/lib/micado/consul/config/*
# Docker install
apt-get update
apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl software-properties-common wget unzip jq dnsmasq
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce=17.09.1~ce-0~ubuntu
export IP=$(hostname -I | cut -d\  -f1)
sed -i -e "s/-H fd:\/\//-H fd:\/\/ -H tcp:\/\/$IP:2375/g" /lib/systemd/system/docker.service
systemctl daemon-reload
service docker restart
# Install Docker Compose
curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
# Start Swarm
docker swarm init --advertise-addr=$IP
docker node update --availability drain $(hostname)
# Update executor IP
export IP=$(hostname -I | cut -d\  -f1)
sed -i -e 's/hostIP/'$IP'/g' /var/lib/micado/prometheus_executor/config/conf.sh
# Start infra. services
curl -L $GITHUB_URL/worker_node/templates/temp_auth_data.yaml --create-dirs -o /var/lib/micado/submitter/data/temp_auth_data.yaml
curl -L $GITHUB_URL/worker_node/templates/temp_node_definitions.yaml --create-dirs -o /var/lib/micado/submitter/data/temp_node_definitions.yaml
curl -L $GITHUB_URL/worker_node/templates/temp_infrastructure_descriptor.yaml  --create-dirs -o /var/lib/micado/submitter/data/temp_infrastructure_descriptor.yaml
curl -L $GITHUB_URL/worker_node/cloud_init_worker.yaml --create-dirs -o /var/lib/micado/occopus/data/nodes/cloud_init_worker.yaml
docker-compose -f /var/lib/micado/docker-compose.yml up -d
chmod 777 /var/lib/micado/prometheus_executor/config/conf.sh
#  - docker network create -d bridge my-net --subnet 172.31.0.0/24
#  - docker run -d --network=my-net --ip="172.31.0.2" -p 9090:9090 -v /etc/:/etc prom/prometheus:v1.8.2
#  - docker run -d --network=my-net --ip="172.31.0.3" -v /etc/alertmanager/:/etc/alertmanager/ -p 9093:9093 prom/alertmanager:v0.12.0
#  - docker run -d --network=my-net --ip="172.31.0.4" -p 9095:9095 -v /etc/prometheus_executor/:/etc/prometheus_executor micado/prometheus_executor:3.0
#  - export IP=$(hostname -I | cut -d\  -f1)
#  - docker run -d --network=my-net --ip="172.31.0.5" -p 8301:8301 -p 8301:8301/udp -p 8300:8300 -p 8302:8302 -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 8600:8600/udp  -v /etc/consul/:/etc/consul  -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt":true}'  consul:1.0.0 agent -server -client=0.0.0.0 -advertise=$IP -bootstrap=true -ui -config-dir=/etc/consul
#  - docker run -d -v /var/run/docker.sock:/var/run/docker.sock -v /etc/prometheus/:/etc/prometheus -v /var/lib/micado/alert-generator/:/var/lib/micado/alert-generator/ -e CONTAINER_SCALING_FILE=/var/lib/micado/alert-generator/scaling_policy.yaml -e ALERTS_FILE_PATH=/etc/prometheus/ -e AUTO_GENERATE_ALERT=False -e DEFAULT_SCALEUP=90 -e DEFAULT_SCALEDOWN=10 -e PROMETHEUS="$IP" micado/alert-generator:1.2
