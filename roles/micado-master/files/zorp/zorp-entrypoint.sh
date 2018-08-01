#!/bin/bash

source /etc/zorp/user_data_zorp.env

PIDFILE_DIR=/var/run/zorp
TEMPDIR=/var/lib/zorp/tmp
KEYFILE_NAME=/etc/zorp/ssl.key
CERTFILE_NAME=/etc/zorp/ssl.pem

function create_pidfile_dir {
    mkdir $PIDFILE_DIR
    chown zorp.zorp $PIDFILE_DIR
    chmod 0770 $PIDFILE_DIR
}

function create_tempdir {
    mkdir $TEMPDIR
    chown zorp.zorp $TEMPDIR
    chmod 0770 $TEMPDIR
}

if [ ! -f $CERTFILE_NAME ]; then
    if [ "x$TLS_PROVISION_METHOD" == "xself-signed" ]; then
        echo "Generating new x509 keypair"
        openssl req -new -newkey rsa:4096 -days 3650 -sha256 -nodes -x509 -subj "/CN=${TLS_PROVISION_HOSTNAME}" -keyout $KEYFILE_NAME -out $CERTFILE_NAME
        chown zorp.zorp $KEYFILE_NAME
        chown zorp.zorp $CERTFILE_NAME
    fi;
    if [ "x$TLS_PROVISION_METHOD" == "xuser-supplied" ]; then
        echo "Saving keypair from env file"
        echo "$TLS_PROVISION_KEY" > $KEYFILE_NAME
        echo "$TLS_PROVISION_CERT" > $CERTFILE_NAME
        chown zorp.zorp $KEYFILE_NAME
        chown zorp.zorp $CERTFILE_NAME
    fi;
    if [ "x$TLS_PROVISION_METHOD" == "xletsencrypt" ]; then
        echo "To be implemented"
    fi;
fi;

create_pidfile_dir
create_tempdir

exec "$@"
