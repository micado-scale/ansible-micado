# Ansible MiCADO

## Table of Contents

* [Introduction](#introduction)
* [Deployment](#deployment)
* [Dashboard](#dashboard)
* [REST API](#rest-api)
* [TOSCA description](#tosca-description)
* [Demo application](#demo-application)

## Introduction

MiCADO is an auto-scaling framework for Docker applications. It supports autoscaling at two levels. At virtual machine (VM) level, a built-in Docker Swarm cluster is dynamically extended or reduced by adding/removing cloud virtual machines. At docker service level, the number of replicas implementing a Docker Service can be increased/decreased.

MiCADO requires a TOSCA based Application Description to be submitted containing three sections: 1) the definition of the interconnected Docker services, 2) the specification of the virtual machine and 3) the implementation of scaling policy for both scaling levels. The format of the Application Description for MiCADO is detailed later.

To use MiCADO, first the MiCADO core services must be deployed on a virtual machine (called MiCADO Master) by an Ansible playbook. MiCADO Master contains Docker engine (configured as Swarm manager), Occopus (to scale VMs), Prometheus (for monitoring), Policy Keeper (to perform decision on scaling) and Submitter (to provide submission endpoint) microservices to realize the autoscaling control loops. During operation MiCADO workers (realised on new VMs) are instantiated on demand which deploy Prometheus Node Exporter, CAdvisor and Docker engine through contextualisation. The Docker engine of the newly instantiated MiCADO workers joins the Swarm manager on the MiCADO Master.

In the current release, the status of the system can be inspected through the following ways: REST API provides interface for submission, update and list functionalities over applications. Dashboard provides three graphical view to inspect the VMs and Docker services. They are Docker Visualizer, Grafana and Prometheus. Finally, advanced users may find the logs of the MiCADO core services useful on MiCADO master.


## Deployment

There are 3 different roles for machines in this scenario:
 - Controller machine: a machine from which you control the MiCADO service installation
 - MiCADO master machine: preferably a virtual machine in cloud on which you will install the core MiCADO services
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

- To launch an application from a file that you pass to the api you can use one of the following curl command line:
```
curl -F file=@[Path to the File] -X POST http://[IP]:[Port]/v1.0/app/launch/file/
```
```
curl -F file=@[Path to the File] -F id=[SOMEID]  -X POST http://[IP]:[Port]/v1.0/app/launch/file/
```

- To launch an application from an url you can use one of the following curl command line:
```
curl -d input="[url to TOSCA Template]" -X POST http://[IP]:[Port]/v1.0/app/launch/url/
```
```
curl -d input="[url to TOSCA Template]" -d id=[ID] -X POST http://[IP]:[Port]/v1.0/app/launch/url/
```

- To update from a file a wanted application you can use one of this following curl command:
```
curl -F file=@"[Path to the file]" -X PUT http://[IP]:[Port]/v1.0/app/udpate/file/[ID_APP]
```
- To update from an url a wanted application you can use one of this following curl command:
```
curl -d input="[url to TOSCA template]" -X PUT http://[IP]:[Port]/v1.0/app/udpate/file/[ID_APP]
```

- To undeploy a wanted application you need to feed it the id:
```
curl -X DELETE http://[IP]:[Port]/v1.0/app/undeploy/[ID_APP]
```
- To get the ids of the application deployed and its information related:
```
curl -X GET http://[IP]:[Port]/v1.0/list_app/
```
- To get only the information for only one app:
```
curl -X GET http://[IP]:[Port]/v1.0/app/[ID_APP]
```


## TOSCA description

The main structure of the TOSCA description. The TOSCA decrpiton has four main part:
- **tosca_definitions_version**: fix value: ```tosca_simple_yaml_1_0```
- **imports**: A list of other TOSCA definitions. We used it to import our custom definied TOSCA types.
- **repositories**: Map of the defined repositories and their addresses.
- **topology_template**: The main part of the TOSCA description to define the application which will be deployed in MiCADO. This section is consist of two main other parts the **node_templates** and the **policies**. This sections will be detaild in the following sections.

```
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - https://raw.githubusercontent.com/micado-scale/tosca/master/micado_types.yaml

repositories:
  docker_hub: https://hub.docker.com/

topology_template:
  node_templates:
    YOUR_DOCKER_SERVICE:
          type: tosca.nodes.MiCADO.Container.Application.Docker
      properties:
            ...
          artifacts:
            ...

    YOUR_VIRTUAL_MACHINE:
          type: tosca.nodes.MiCADO.Occopus.<CLOUD_API_TYPE>.Compute
      properties:
        cloud:
          interface_cloud: ...
          endpoint_cloud: ...
      capabilities:
        host:
          properties:
                    ...

  policies:
  - scalability:
    type: tosca.policies.Scaling.MiCADO
    targets: [ YOUR_VIRTUAL_MACHINE ]
        properties:
      ...

  - scalability:
    type: tosca.policies.Scaling.MiCADO
    targets: [ YOUR_DOCKER_SERVICE ]
        properties:
      ...
```

### Docker based application description

The TOSCA template Docker relevnat part has a following structure. Under the node_templates section you can define one docker service. One docker service definiton is consit of three main part: type, properties, artifacts. The type has a fix value: ```tosca.nodes.MiCADO.Container.Application.Docker```. The properties section will be discussed later. Under the artifacts section you could define the docker image for the service. Optionally, you can define docker networks under the YOUR_DOCKER_NETWORK section like in a docker-compose file.

```
topology_template:
  node_templates:
    YOUR_DOCKER_SERVICE:
      type: tosca.nodes.MiCADO.Container.Application.Docker
      properties:
         ...
      artifacts:
       image:
         type: tosca.artifacts.Deployment.Image.Container.Docker
         file: YOUR_DOCKER_IMAGE
         repository: docker_hub
    YOUR_DOCKER_NETWORK:
      type: tosca.nodes.MiCADO.network.Network.Docker
      properties:
        ...
```

The properties are based on the original docker-compose file fields. Therefore, you can find more information about the properties in the [docker compose documentation](https://docs.docker.com/compose/compose-file/#service-configuration-reference). The syntax of the property values is the same as in the docker-compose file.

Under the YOUR_DOCKER_SERVICE properties section you can add your docker service specific properties. 
- **command**: command line expression to be executed by the container.
- **deploy**: Swarm specific deployment options.
- **entrypoint**: Override the default entrypoint of container.
- **environment**: Map of all required environment variables.
- **expose**: Expose ports without publishing them to the host machine.
- **labels**: Map of metadata like Docker labels.
- **logging**: Map of the logging configuration.
- **networks**: List of connected networks for the service.
- **volumes**: List of connected volumes for the service.
- **ports**: List of published ports to the host machine.
- **secrets**: List of per-service secrets to grant access for the service.

Under the artifacts section you can defined the docker image for the docker service. In the image section you can define three fileds:
- **type**: fix value: ```tosca.artifacts.Deployment.Image.Container.Docker```
- **file**: Your docker image for the docker service. (e.g. sztakilpds/cqueue_frontend:latest )
- **repository**: The name of the repository where the image is located. This name have to be defined in the top of the TOSCA file. (e.g. docker_hub)

Under the YOUR_DOCKER_NETWORK section you can set the following fields for the docker network:

- **attachable**: If set to true, then standalone containers can attach to this network, in addition to services
- **driver**: Specify which driver should be used for this network. (overlay, bridge, etc.)

### Virtual Machine description
The TOSCA template occopus relevant part looks like this. Currently we support 4 cloud interface.

#### CloudSigma
```
topology_template:
  node_templates:
    worker_node:
      type: tosca.nodes.MiCADO.Occopus.CloudSigma.Compute
      properties:
        cloud:
          interface_cloud: cloudsigma
          endpoint_cloud: ADD_YOUR_ENDPOINT (e.g for cloudsigma https://zrh.cloudsigma.com/api/2.0 )
      capabilities:
        host:
          properties:
            num_cpus: ADD_NUM_CPUS_FREQ (e.g. 4096)
            mem_size: ADD_MEM_SIZE (e.g. 4294967296)
            vnc_password: ADD_YOUR_PW (e.g. secret)
            libdrive_id: ADD_YOUR_ID_HERE (eg. 87ce928e-e0bc-4cab-9502-514e523783e3)
            public_key_id: ADD_YOUR_ID_HERE (e.g. d7c0f1ee-40df-4029-8d95-ec35b34dae1e)
            firewall_policy: ADD_YOUR_ID_HERE (e.g. fd97e326-83c8-44d8-90f7-0a19110f3c9d)
```

The Occopus adaptor **requires** libdrive_id, num_cpus, mem_size, vnc_password and public_key_id to create a valid *CloudSigma* node definition. You could also give some other properties to extends your description. The properties could be found below.

- **libdrive_id** is the image id (e.g. 87ce928e-e0bc-4cab-9502-514e523783e3) on your CloudSigma cloud. Select an image containing a base os installation with cloud-init support!
- **num_cpu** is the speed of CPU (e.g. 4096) in terms of MHz of your VM to be instantiated. The CPU frequency required to be between 250 and 100000
- **mem_size** is the amount of RAM (e.g. 4294967296) in terms of bytes to be allocated for your VM. The memory required to be between 268435456 and 137438953472
- **vnc_password** set the password for your VNC session (e.g. secret).
- **public_key_id** specifies the keypairs (e.g. d7c0f1ee-40df-4029-8d95-ec35b34dae1e) to be assigned to your VM.
- **firewall_policy** optionally specifies network policies (you can define multiple security groups in the form of a list, e.g. fd97e326-83c8-44d8-90f7-0a19110f3c9d) of your VM.

#### CloudBroker
```
topology_template:
  node_templates:
    worker_node:
      type: tosca.nodes.MiCADO.Occopus.CloudBroker.Compute
      properties:
        cloud:
          interface_cloud: cloudbroker
          endpoint_cloud: ADD_YOUR_ENDPOINT (e.g for cloudsigma https://zrh.cloudsigma.com/api/2.0 )
      capabilities:
        host:
          properties:
            deployment_id: ADD_YOUR_ID_HERE (e.g. e7491688-599d-4344-95ef-aff79a60890e)
            instance_type_id: ADD_YOUR_ID_HERE (e.g. 9b2028be-9287-4bf6-bbfe-bcbc92f065c0)

```

The Occopus adaptor **requires** deployment_id and instance_type_id to create a valid *CloudBroker* node definition. You could also give some other properties to extends your description. The properties could be found below.

- **deployment_id** is the id of a preregistered deployment in CloudBroker referring to a cloud, image, region, etc. Make sure the image contains a base os (preferably Ubuntu) installation with cloud-init support! The id is the UUID of the deployment which can be seen in the address bar of your browser when inspecting the details of the deployment.
- **instance_type_id** is the id of a preregistered instance type in CloudBroker referring to the capacity of the virtual machine to be deployed. The id is the UUID of the instance type which can be seen in the address bar of your browser when inspecting the details of the instance type.
- **key_pair_id** is the id of a preregistered ssh public key in CloudBroker which will be deployed on the virtual machine. The id is the UUID of the key pair which can be seen in the address bar of your browser when inspecting the details of the key pair.
- **opened_port** is one or more ports to be opened to the world. This is a string containing numbers separated by a comma.

#### EC2
```
topology_template:
  node_templates:
    worker_node:
      type: tosca.nodes.MiCADO.Occopus.EC2.Compute
      properties:
        cloud:
          interface_cloud: ec2
          endpoint_cloud: ADD_YOUR_ENDPOINT (e.g for cloudsigma     ec2.eu-west-1.amazonaws.com )
      capabilities:
        host:
          properties:
            region_name: ADD_YOUR_REGION_NAME_HERE (e.g. eu-west-1)
            image_id: ADD_YOUR_ID_HERE (e.g. ami-12345678)
            instance_type: ADD_YOUR_INSTANCE_TYPE_HERE (e.g. t1.small)
```

The Occopus adaptor **requires** region_name, image_id and instance_type to create a valid *EC2* node definition. You could also give some other properties to extends your description. The properties could be found below.

- **region_name** is the region name within an EC2 cloud (e.g. eu-west-1).
- **image_id** is the image id (e.g. ami-12345678) on your EC2 cloud. Select an image containing a base os installation with cloud-init support!
- **instance_type** is the instance type (e.g. t1.small) of your VM to be instantiated.
- **key_name** optionally specifies the keypair (e.g. my_ssh_keypair) to be deployed on your VM.
- **security_groups_ids** optionally specify security settings (you can define multiple security groups in the form of a list, e.g. sg-93d46bf7) of your VM.
- **subnet_id** optionally specifies subnet identifier (e.g. subnet-644e1e13) to be attached to the VM.

#### Nova
```
topology_template:
  node_templates:
    worker_node:
      type: tosca.nodes.MiCADO.Occopus.Nova.Compute
      properties:
        cloud:
          interface_cloud: nova
          endpoint_cloud: ADD_YOUR_ENDPOINT (e.g for cloudsigma https://zrh.cloudsigma.com/api/2.0 )
      capabilities:
        host:
          properties:
            image_id: ADD_YOUR_ID_HERE (e.g. d4f4e496-031a-4f49-b034-f8dafe28e01c)
            flavor_name: ADD_YOUR_ID_HERE (e.g. 3)
            project_id: ADD_YOUR_ID_HERE (e.g. a678d20e71cb4b9f812a31e5f3eb63b0)
            network_id: ADD_YOUR_ID_HERE (e.g. 3fd4c62d-5fbe-4bd9-9a9f-c161dabeefde)
```

Under the properties field, you can add your cloudspecific properties. There are some required, and the others are optional. See more details below.

The Occopus adaptor **requires** image_id flavor_name, project_id and network_id to create a valid *Nova* node definition. You could also give some other properties to extends your description. The properties could be found below.

- **project_id** is the id of project you would like to use on your target Nova cloud.
- **image_id** is the image id on your Nova cloud. Select an image containing a base os installation with cloud-init support!
- **flavor_name** is the name of flavor to be instantiated on your Nova cloud.
- **server_name** optionally defines the hostname of VM (e.g.:”helloworld”).
- **key_name** optionally sets the name of the keypair to be associated to the instance. Keypair name must be defined on the target nova cloud before launching the VM.
- **security_groups** optionally specify security settings (you can define multiple security groups in the form of a list) for your VM.
- **network_id** is the id of the network you would like to use on your target Nova cloud.

### Policy description



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
