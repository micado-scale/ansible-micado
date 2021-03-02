#!/usr/bin/env python3

import json, time, os

tf_file = "/var/lib/micado/terraform/preprocess/egi/token.txt"
tfvars_file = "/var/lib/micado/terraform/submitter/terraform.tfvars.json"
cmd_egi = "python3 /var/lib/micado/terraform/preprocess/egi/pyGetScopedToken.py"
delta = 120

def load_json(path):
    """ Load the dictionary from a json file """

    with open(path, "r") as file:
        data = json.load(file)

    return data

def dump_json(data, path):
    """ Dump the dictionary to a json file """

    with open(path, "w") as file:
        json.dump(data, file, indent=4)

def update_token(token_dict):
    """ Update the token in tfvars file """

    data = load_json(tf_file)
    now = int(time.time())
    gen_time = data["time"]
    if (now-gen_time) < (3600-delta):
        token_dict["ostoken"] = data["token"]
    else:
        os.system(cmd_egi)
        data = load_json(tf_file)
        token_dict["ostoken"] = data["token"]

    return token_dict

def preprocess_egi(token_dict):
    """ Preprocessing for egi """

    if not os.path.exists(tf_file):
        os.system(cmd_egi)
        tfvars_dict = update_token(token_dict)
    else:
        tfvars_dict = update_token(token_dict)

    dump_json(tfvars_dict,tfvars_file)


def main():

    token_dict = load_json(tfvars_file)

    if token_dict["preprocess"]:
        cloud = token_dict["preprocess"]
        if cloud == "egi.eu":
            preprocess_egi(token_dict)


if __name__ == "__main__":
        main()