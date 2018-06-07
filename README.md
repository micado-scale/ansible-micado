# Deploy Micado with Ansible

There are 3 different roles for machines in this scenario:
 - Controller machine: a machine from which you control the MiCADO service installation
 - MiCADO master machine: preferebly a virtual machine in cloud on which you will install the core MiCADO services
 - MiCADO worker machine(s): further virtual machine(s) in cloud which will be automatically launched by the core MiCADO services

## Prerequisites

 - All 3 type of machines should be Ubuntu 16.04
 - Installed ansible and git is needed on the Controller machine

## Installation

Perform the following steps on the Controller machine:

### Step 1: Download the Micado ansible playbook

```
git clone https://github.com/micado-scale/ansible-micado.git ansible-micado
cd ansible-micado
git checkout 0.3.x
```

### Step 2: Specify details for instantiating MiCADO worker nodes

```
cp sample-credentials.yml credentials.yml
```
Edit credentials.yml to add all cloud-related information for worker instantiation

### Step 3: Launch an empty cloud VM instance on which core MiCADO services will be installed

Use any of aws, ec2, nova command-line tools or web interface of the target cloud. Make sure you can ssh to it (without password) and your user is a sudoer. Store its IP address which will be referred as `IP` in the following steps.

### Step 4: Make sure python 2.7 is installed on the MiCADO master machine

```
ssh <IP> sudo apt-get --yes install python
```

### Step 5: Set target machine in the 'hosts' file

```
cp sample-hosts hosts
```
Edit the `hosts` file (on the Cotnroller machine) to set ansible variables like host, connection, user, etc. for MiCADO master machine. Do not forget to set `ansible_host=<IP>` and `ansible_connection=ssh`.

### Step 6: Update ansible on the MiCADO master node

```
ansible-playbook -i hosts update-ansible.yml
```

### Step 7: Launch the installation of core MiCADO services

```
ansible-playbook -i hosts micado-master.yml
```

## Health checking

At the end of the deployment, core MiCADO services will be running on the MiCADO master machine. Here are the commands to test the operation of some of the core MiCADO services:

- Occopus:
```curl -s -X GET http://IP:5000/infrastructures/micado_worker_infra```
- Swarm
```curl -s http://IP:2375/swarm | jq '.JoinTokens'```
- Prometheus
```curl -s http://IP:9090/api/v1/status/config | jq '.status'```

## Monitoring

MiCADO exposes the following webpages:
- Dashboard:
```http://IP:4000```
- Prometheus:
```http://IP:9090```
- Docker visualizer:
```http://IP:8080```
- Grafana:
```http://IP:3000/d/micado```

## Testing

You can find test application(s) under the subdirectories of the 'testing' directory.

- stressng

  This application contains a single service, performing constant load. Policy defined for this application scales up/down both nodes and the stressng service based on cpu consumption. Both compose and policy files are ready to be submitted with the helper scripts:
  - Step1: set the MICADO_MASTER variable to contain the IP of the MiCADO master with ```export MICADO_MASTER=x.x.x.x```
  - Step2: run ```1-submit-tosca-stressng.sh``` to deploy the virtual machine and stressng service using TOSCA *optionally add as an argument a user-defined app_id (ie. ```1-submit-tosca-stressng.sh <app_id>``` ). Observe the scaleup response
  - Step2a: run ```2-list-apps.sh``` to see currently running applications and their IDs
  - Step3: run ```3-update-tosca-stressng.sh <app_id>``` to update the service and reduce the CPU load. Observe the scaledown response.
  - Step4: run ```4-undeploy-with-id.sh <app_id>``` to remove the stressng service and the virtual machine node
