if [ -z "$MICADO_MASTER" ]; then
    if [[ $# -eq 0 ]] ; then
       echo 'Please, specify the master ip address (or set MICADO_MASTER!)'
       exit 1
    fi
    if [[ $# -gt 2 ]] ; then
       echo 'Please, specify only one ip address!'
       exit 1
    fi
    MICADO_MASTER=$2
fi

curl -X GET http://$MICADO_MASTER:5050/v1.0/list_app
