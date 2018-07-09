# Ansible MiCADO

## Table of Contents

* [Inroduction](#inroduction)
* [Deployment](#deployment)
* [Dashboard](#dashboard)
* [REST API](#rest-api)
* [TOSCA description](#tosca-description)
* [Demo application](#demo-application)

## Inroduction


## Deployment

There are 3 different roles for machines in this scenario:
 - Controller machine: a machine from which you control the MiCADO service installation
 - MiCADO master machine: preferebly a virtual machine in cloud on which you will install the core MiCADO services
 - MiCADO worker machine(s): further virtual machine(s) in cloud which will be automatically launched by the core MiCADO services

### Prerequisites

 - All 3 type of machines should be Ubuntu 16.04
 - Installed ansible and git is needed on the Controller machine

### Installation

Perform the following steps on the Controller machine:

#### Step 1: Download the Micado ansible playbook

```
git clone https://github.com/micado-scale/ansible-micado.git ansible-micado
cd ansible-micado
git checkout master
```

#### Step 2: Specify details for instantiating MiCADO worker nodes

```
cp sample-credentials.yml credentials.yml
```
Edit credentials.yml to add all cloud-related information for worker instantiation.

##### Optional: Specify details for Docker login and private Docker repositories

```
cp sample-docker-cred.yml docker-cred.yml
```
Edit docker-cred.yml and add username, password, and repository url.
To login to the default docker_hub, leave DOCKER_REPO as is (a blank string).

#### Step 3: Launch an empty cloud VM instance on which core MiCADO services will be installed

Use any of aws, ec2, nova command-line tools or web interface of the target cloud. Make sure you can ssh to it (without password) and your user is a sudoer. Store its IP address which will be referred as `IP` in the following steps.

#### Step 4: Make sure python 2.7 is installed on the MiCADO master machine

```
ssh <IP> sudo apt-get --yes install python
```

#### Step 5: Set target machine in the 'hosts' file

```
cp sample-hosts hosts
```
Edit the `hosts` file (on the Cotnroller machine) to set ansible variables like host, connection, user, etc. for MiCADO master machine. Do not forget to set `ansible_host=<IP>` and `ansible_connection=ssh`.

#### Step 6: Update ansible on the MiCADO master node

```
ansible-playbook -i hosts update-ansible.yml
```

#### Step 7: Launch the installation of core MiCADO services

```
ansible-playbook -i hosts micado-master.yml
```

### Health checking

At the end of the deployment, core MiCADO services will be running on the MiCADO master machine. Here are the commands to test the operation of some of the core MiCADO services:

- Occopus:
```curl -s -X GET http://IP:5000/infrastructures/micado_worker_infra```
- Swarm
```curl -s http://IP:2375/swarm | jq '.JoinTokens'```
- Prometheus
```curl -s http://IP:9090/api/v1/status/config | jq '.status'```

## Dashboard

MiCADO exposes the following webpages:

- Dashboard:
```http://IP:4000```
- Prometheus:
```http://IP:9090```
- Docker visualizer:
```http://IP:8080```
- Grafana:
```http://IP:3000/d/micado```

## REST API

## TOSCA description

## Demo application

You can find test application(s) under the subdirectories of the 'testing' directory. The current tests are written for CloudSigma.

- stressng

  This application contains a single service, performing constant load. Policy defined for this application scales up/down both nodes and the stressng service based on cpu consumption. Helper scripts has been added to the directory to ease application handling.
  - Step1: add your ```public_key_id``` to both the ```stressng.yaml``` and ```stressng-update.yaml``` files. Without this CloudSigma does not execute the contextualisation on the MiCADO worker nodes. The ID must point to your public ssh key under your account in CloudSigma. You can find it on the CloudSigma Web UI under the "Access & Security/Keys Management" menu.
  - Step2: add a proper ```firewall_policy``` to both the ```stressng.yaml``` and ```stressng-update.yaml``` files. Without this MiCADO master will not reach MiCADO worker nodes. Firewall policy ID can be retrieved from a rule defined under the "Networking/Policies" menu. The following ports must be opened for MiCADO workers: all inbound connections from MiCADO master <to be defined in more detials>
  - Step3: set the MICADO_MASTER variable to contain the IP of the MiCADO master node with ```export MICADO_MASTER=a.b.c.d```
  - Step4: run ```1-submit-tosca-stressng.sh``` to create the minimum number of MiCADO worker nodes and to deploy the docker stack including the stressng service defined in the ```stressng.yaml``` TOSCA description. Optionally, add as an argument a user-defined application id (ie. ```1-submit-tosca-stressng.sh stressng``` ). Observe the scaleup response
  - Step4a: run ```2-list-apps.sh``` to see currently running applications and their IDs
  - Step5: run ```3-update-tosca-stressng.sh stressng``` to update the service and reduce the CPU load. Observe the scaledown response.
  - Step6: run ```4-undeploy-with-id.sh stressng``` to remove the stressng stack and all the MiCADO worker nodes
