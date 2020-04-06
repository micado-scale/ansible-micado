# MiCADO - autoscaling framework for Docker services on Cloud

This software was developed as part of the now completed [COLA project](https://project-cola.eu/). The University of Westminster (U.K.) and MTA SZTAKI (Hungary) will continue its open-source development as part of other research projects.

MiCADO is an auto-scaling framework for Docker applications. It supports autoscaling at two levels. At virtual machine (VM) level, a built-in Kubernetes cluster is dynamically extended or reduced by adding/removing Nodes hosted on cloud virtual machines. At container level, the number of replicas implementing a Docker Service is automatically increased/decreased. The application detailing the services, links and scaling rules must be specified by a TOSCA-based Application Description Template (ADT).

The MiCADO manual is hosted at https://micado-scale.readthedocs.io .

Manuals for MiCADO versions are as follows, and there is a very basic quick start guide below:
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
* Ubuntu 16.04 LTS or 18.04 LTS
* On a supported cloud
  * AWS EC2
  * CloudSigma
  * CloudBroker
  * OpenStack
  * Microsoft Azure
  * Google Cloud

### 1x Ansible Remote (or locally on Master)

* Ansible >= v2.8
* curl
* jq (for demos)
* wrk (for demos)

## Set-up

Clone the repository & prepare the credentials:

    git clone https://github.com/micado-scale/ansible-micado micado
    cd micado
    git checkout v0.9.0
    cp sample-hosts.yml hosts.yml
    cp sample-credentials-cloud-api.yml credentials-cloud-api.yml
    cp sample-credentials-micado.yml credentials-micado.yml
    #option to login to private registry# cp sample-credentials-docker-registry.yml credentials-docker-registry.yml

Fill the *hosts* file with values for *ansible_host (Master IP)* and *ansible_user (SSH user)* and fill the *credentials-* files with usernames & passwords:

    vim hosts.yml
    vim credentials-cloud-api.yml
    vim credentials-micado.yml
    #option to login to private registry# vim credentials-docker-registry.yml

Run the playbook to completion:

    ansible-playbook -i hosts.yml micado-master.yml

#### Now view the MiCADO Dashboard at https://<MiCADO_Master_IP>

## Testing

Prepare a demo by filling *_settings* with your MiCADO Master IP and user/pass:

    cd demos/stressng
    vim _settings

Fill the required fields (**ADD_YOUR_ID ...**) under the **worker-node** virtual machine with IDs from your cloud service provider, then run the test scripts:

    cp stressng_<yourcloud>.yaml stressng.yaml
    vim stressng.yaml
    ./1-submit-tosca-stressng.sh
    ./2-list-apps.sh
    ./3-stress-cpu-stressng.sh 85

Check out the Dashboard to see the test scale up, and undeploy when done:

    ./4-undeploy-stressng.sh
