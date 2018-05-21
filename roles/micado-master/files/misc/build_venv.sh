#!/bin/bash

pip3 install virtualenv
cd /var/lib/micado/
virtualenv tosca-submitter
source tosca-submitter/bin/activate
pip3 install ruamel.yaml flask tosca-parser gunicorn
cd tosca-submitter
git clone https://github.com/micado-scale/component_submitter.git
cd component_submitter
screen -dm gunicorn -b 0.0.0.0:5050 api:app
