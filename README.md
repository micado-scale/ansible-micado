# MiCADO - autoscaling framework for Docker services on Cloud

This software was developed as part of the now completed [COLA project](https://project-cola.eu/). The University of Westminster (U.K.) and MTA SZTAKI (Hungary) will continue its open-source development as part of other research projects.

MiCADO is an auto-scaling framework for Docker applications. It supports autoscaling at two levels. At virtual machine (VM) level, a built-in Kubernetes cluster is dynamically extended or reduced by adding/removing Nodes hosted on cloud virtual machines. At container level, the number of replicas implementing a Docker Service is automatically increased/decreased. The application detailing the services, links and scaling rules must be specified by a TOSCA-based Application Description Template (ADT).

The MiCADO manual is hosted at https://micado-scale.readthedocs.io .

Manuals for MiCADO versions are as follows, and there is a very basic quick start guide below:
 - [MiCADO v0.9.2](https://micado-scale.readthedocs.io/en/0.9.2)
 - [MiCADO v0.9.1-rev1](https://micado-scale.readthedocs.io/en/0.9.1-rev1)
 - [MiCADO v0.9.1](https://micado-scale.readthedocs.io/en/0.9.1)
 - [MiCADO v0.9.0](https://micado-scale.readthedocs.io/en/0.9.0)
 - [MiCADO v0.8.0](https://micado-scale.readthedocs.io/en/0.8.0)
 - [MiCADO v0.7.3](https://micado-scale.readthedocs.io/en/0.7.3)
 - [MiCADO v0.7.2-rev1](https://micado-scale.readthedocs.io/en/0.7.2-rev1)
 - [MiCADO v0.7.2](https://micado-scale.readthedocs.io/en/0.7.2)
 - [MiCADO v0.7.1](https://micado-scale.readthedocs.io/en/0.7.1)
 - [MiCADO v0.7.0](https://micado-scale.readthedocs.io/en/0.7.0)
 - [MiCADO v0.6.1](https://micado-scale.readthedocs.io/en/0.6.1)
 - [MiCADO v0.6.0](https://micado-scale.readthedocs.io/en/0.6.0)
 - [MiCADO v0.5.0](https://micado-scale.readthedocs.io/en/0.5.0)

# Quick Start Guide

## Requirements

### 1x MiCADO Master

* 2 CPU / 4GB RAM / 20GB DISK
* Ubuntu 18.04 or 20.04
* On a supported cloud
  * AWS EC2
  * CloudSigma
  * CloudBroker
  * OpenStack
  * Microsoft Azure
  * Google Cloud
  * Oracle Cloud Infrastructure

### 1x Ansible machine (could be your laptop, or a VM instance)

* Ansible >= v2.9
* curl
* jq (for demos)
* wrk (for demos)

## Set-up

Clone the repository & fill in connection details and credentials. In the *hosts* file,
complete values for *ansible_host (Master IP)* and *ansible_user (SSH user)*. In the
*credentials-* files provide usernames & passwords according to cloud, desired MiCADO
WebUI access and/or private container registry:

```bash
MICADO_PATH=/home/ubuntu/micado
git clone https://github.com/micado-scale/ansible-micado $MICADO_PATH
PLAYBOOK_PATH=$MICADO_PATH/getmicado/playbook

cd $PLAYBOOK_PATH
git checkout v0.9.2

cd $PLAYBOOK_PATH/inventory
cp sample-hosts.yml hosts.yml
edit hosts.yml

cd $PLAYBOOK_PATH/project/credentials
cp sample-credentials-cloud-api.yml credentials-cloud-api.yml
cp sample-credentials-micado.yml credentials-micado.yml
edit credentials-cloud-api.yml
edit credentials-micado.yml

#optional for private registry login#
cp sample-credentials-docker-registry.yml credentials-docker-registry.yml
edit credentials-docker-registry.yml
```

Run the **micado.yml** playbook to completion:

```bash
cd $PLAYBOOK_PATH
ansible-playbook project/micado.yml
```

#### Now view the MiCADO Dashboard at https://<MiCADO_Master_IP>

## Testing

Prepare a demo by filling *_settings* with your MiCADO Master IP and user/pass:

```bash
cd $MICADO_PATH/demos/stressng
edit _settings
```

Fill the required fields (**ADD_YOUR_ID ...**) under the **worker-node** virtual machine with IDs from your cloud service provider, then run the test scripts:

```bash
cp stressng_<yourcloud>.yaml stressng.yaml
edit stressng.yaml
./1-submit-tosca-stressng.sh
./2-list-apps.sh
./3-stress-cpu-stressng.sh 85
```

Check out the Dashboard to see the test scale up, and undeploy when done:

```bash
./4-undeploy-stressng.sh
```

## Edges

Using the *sample-hosts-with-edges* file as a reference, fill values under the `micado` key as before, pointing at the MiCADO master. Under the `edgenodes` key, add as many **uniquely** named edge devices as desired, specifying their IPs as *ansible_host* and SSH username as *ansible_user*

```bash
cd $PLAYBOOK_PATH/inventory
cp sample-hosts-with-edges.yml hosts.yml
edit hosts.yml
```

Run the **edge.yml** playbook to completion:

```bash
cd $PLAYBOOK_PATH
ansible-playbook project/edge.yml
```

**When viewing the MiCADO Dashboard, check `Nodes` under**
**the Kubernetes Dashboard to confirm your Edge device(s) are connected**