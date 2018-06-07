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
APP_ID=$1

if [ -z "$APP_ID" ]; then
    curl -F file=@"stressng.yaml" -X POST http://$MICADO_MASTER:5050/v1.0/app/launch/file/
else
    curl -F file=@"stressng.yaml" -F id=$APP_ID -X POST http://$MICADO_MASTER:5050/v1.0/app/launch/file/
fi
