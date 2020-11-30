#!/usr/bin/env python3

import requests
import jwt
import json, time, os
from urllib.parse import urlparse, urlunparse, urljoin

# EGI AAI Check-In settings
client_id = os.getenv('CHECKIN_CLIENT_ID')
client_secret = os.getenv('CHECKIN_CLIENT_SECRET')
refresh_token = os.getenv('CHECKIN_REFRESH_TOKEN')
checkin_auth_url = os.getenv('CHECKIN_AUTH_URL')

# OpenStack settings
os_auth_url= os.getenv('OS_AUTH_URL')
os_project_id= os.getenv('OS_PROJECT_ID')

def get_OIDC_Token(checkin_auth_url, client_id, client_secret, refresh_token):
    ''' Get an OIDC token from the EGI AAI Check-In service '''

    # Creating the paylod for the request
    payload = {'client_id': client_id, 
               'client_secret': client_secret,
               'grant_type': 'refresh_token',
               'refresh_token': refresh_token,
               'scope': 'openid email profile'}

    curl = requests.post(url=checkin_auth_url, 
           auth=(client_id, client_secret), data=payload)
    data = curl.json()

    # Server response
    return (data["access_token"])


def get_unscoped_token(os_auth_url, access_token):
    ''' Retrieve an uscoped token from OpenStack Keystone '''

    url = get_keystone_url(os_auth_url,
          "/v3/OS-FEDERATION/identity_providers/egi.eu/protocols/openid/auth")

    curl = requests.post(url, headers={'Authorization': 'Bearer %s' % access_token})
    return curl.headers['X-Subject-Token']

def get_keystone_url(os_auth_url, path):
    ''' Get Keystone URL '''

    url = urlparse(os_auth_url)
    prefix = url.path.rstrip('/')
    if prefix.endswith('v2.0') or prefix.endswith('v3'):
       prefix = os.path.dirname(prefix)

    path = os.path.join(prefix, path)

    return urlunparse((url[0], url[1], path, url[3], url[4], url[5]))

def get_scoped_Token(os_auth_url, os_project_id, unscoped_token):
    ''' Get scoped token '''

    url = get_keystone_url(os_auth_url, "/v3/auth/tokens")

    token_body = {
       "auth": {
           "identity": {
                "methods": ["token"],
                "token": {"id": unscoped_token}
           },
           "scope": {"project": {"id": os_project_id}}
       }
    }

    r = requests.post(url, headers={'content-type': 'application/json'}, 
                 data=json.dumps(token_body))

    return r.headers['X-Subject-Token']


def main():
        # Retrive an OIDC token from the EGI AAI Check-In service.
    token = get_OIDC_Token(checkin_auth_url, client_id, client_secret, refresh_token)
    
    # Check whether the token is valid
    payload = jwt.decode(token, verify=False)
    now = int(time.time())
    expires = int(payload['exp'])
    if (expires-now) > 300:
       # Get the Keystone URL
       url = get_keystone_url(os_auth_url, "/v3/auth/tokens")
       # Retrieve an OpenStack scoped token 
       scoped_token = get_scoped_Token(os_auth_url, os_project_id, get_unscoped_token(os_auth_url, token))

       print ("%s" %scoped_token)

if __name__ == "__main__":
        main()
