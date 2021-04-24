#!/usr/bin/env python3

import json

def load_json(path):
    """ Load the dictionary from a json file """

    with open(path, "r") as file:
        data = json.load(file)

    return data

def dump_json(data, path):
    """ Dump the dictionary to a json file """

    with open(path, "w") as file:
        json.dump(data, file, indent=4)