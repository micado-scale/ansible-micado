if [ -z "$MICADO_MASTER" ]; then
    if [[ $# -eq 0 ]] ; then
        echo 'Please, specify the ip address or set MICADO_MASTER!'
        exit 1
    fi
    if [[ $# -gt 1 ]] ; then
        echo 'Please, specify only one ip address!'
        exit 1
    fi
    MICADO_MASTER=$1
fi

curl --data-binary @stressng.yaml -X POST http://$MICADO_MASTER:5050/v1.0/app/launch/file/
