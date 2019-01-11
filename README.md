# MiCADO - autoscaling framework for Docker services on Cloud

This software is developed by the [COLA project](https://project-cola.eu/).

MiCADO is an auto-scaling framework for Docker applications. It supports autoscaling at two levels. At virtual machine (VM) level, a built-in Docker Swarm cluster is dynamically extended or reduced by adding/removing docker nodes hosted on cloud virtual machines. At container level, the number of replicas implementing a Docker Service is automatically increased/decreased. The application detailing the services, links and scaling rules must be specified by a TOSCA description.

MiCADO manual is hosted at https://micado-scale.readthedocs.io .

Manuals for MiCADO versions are as follows:
 - [MiCADO 0.7.1](https://micado-scale.readthedocs.io/en/0.7.1)
 - [MiCADO 0.7.0](https://micado-scale.readthedocs.io/en/0.7.0)
 - [MiCADO 0.6.1](https://micado-scale.readthedocs.io/en/0.6.1)
 - [MiCADO 0.6.0](https://micado-scale.readthedocs.io/en/0.6.0)
 - [MiCADO 0.5.0](https://micado-scale.readthedocs.io/en/0.5.0)
