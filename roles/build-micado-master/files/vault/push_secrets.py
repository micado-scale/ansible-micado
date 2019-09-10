import yaml
import sys

import requests


def push_secret(key, value, spm):
    data = { "name": key, "value": value }
    try:
        requests.post(spm, json=data)
    except Exception as error:
        print("Error connecting spm: " + str(error))


def push_secrets(secrets, spm):
    for secret in secrets:
        type = secret['type']
        for key, value in secret['auth_data'].items():
            push_secret('.'.join((type, key)), value, spm)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Expected: {} <SPM host>".format(sys.argv[0]))

    spm = sys.argv[1]
    secrets = yaml.load(sys.stdin)
    push_secrets(secrets['resource'], 'http://{}:5003/v1.0/secrets'.format(spm))
