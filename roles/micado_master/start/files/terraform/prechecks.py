#!/usr/bin/env python3

import json, time, os
from utils import load_json,dump_json
from egi_preprocess import preprocess_egi

tfvars_file = "/var/lib/micado/terraform/submitter/terraform.tfvars.json"

def main():

    token_dict = load_json(tfvars_file)

    if token_dict["preprocess"]:
        cloud = token_dict["preprocess"]
        if cloud == "egi.eu":
            preprocess_egi(token_dict)

if __name__ == "__main__":
        main()