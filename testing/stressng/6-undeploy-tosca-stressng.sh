
if [ -z "$MICADO_MASTER" ]; then
    if [[ $# -eq 0 ]] ; then
       echo 'Please, specify the app_id AND ip address (or set MICADO_MASTER!)'
       exit 1
    fi
    if [[ $# -gt 2 ]] ; then
       echo 'Please, specify only one ip address!'
       exit 1
    fi
    MICADO_MASTER=$2
fi
ID_APP=$1

curl -d id_app=$ID_APP -X POST http://$MICADO_MASTER:5050/engine/
