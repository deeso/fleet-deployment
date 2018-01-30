#!/bin/bash
# sh install.sh -host fleet.internal.thecoverofnight.com \
# -crt https://gist.githubusercontent.com/deeso/1234/raw/1234/fleetserver-ca.crt \
# -secret s3kr3t
USAGE="Usage: `basename $0` -help | -host [host] -ca [HTTP_LOC_CERT] -secret [OSQUERY_SECRET]"
OSQUERY=/usr/bin/osqueryd

BASE=/opt/fleet-host/
FHRUNNER=$BASE/fleet-host-run.sh
OSQUERY_SECRET_PATH=$BASE/secret.txt
TSSL=$BASE/ssl/
SSL_CA=$TSSL/fleetserver-ca.crt
TMP_CA=/tmp/fleetserver-ca.crt

ISERVICE=fleet-host-service.sh
SERVICE=fleet-host-service
FSERVICE=/etc/init.d/$SERVICE

if [ "$1" == "-help" ]; then
  echo $USAGE
  exit 0
fi

TLS_HOST=
if [ "$1" == "-host" ]; then
    TLS_HOST=$2
else
    echo $USAGE
    exit 0
fi

CA_LOC=
if [ "$3" == "-ca" ]; then
    wget --no-check-certificate -O $TMP_CA $4 
    CA_LOC=$TMP_CA
else
    echo $USAGE
    exit 0
fi

OSQUERY_SECRET=
if [ "$5" == "-secret" ]; then
    OSQUERY_SECRET=$6
else
    echo $USAGE
    exit 0
fi



CMD_TEMPLATE="#!/bin/bash

$OSQUERY \
--enroll_secret_path=$OSQUERY_SECRET_PATH \
--tls_server_certs=$SSL_CA \
--tls_hostname=$TLS_HOST \
--host_identifier=uuid \
--enroll_tls_endpoint=/api/v1/osquery/enroll \
--config_plugin=tls \
--config_tls_endpoint=/api/v1/osquery/config \
--config_tls_refresh=10 \
--disable_distributed=false \
--distributed_plugin=tls \
--distributed_interval=10 \
--distributed_tls_max_attempts=3 \
--distributed_tls_read_endpoint=/api/v1/osquery/distributed/read \
--distributed_tls_write_endpoint=/api/v1/osquery/distributed/write \
--logger_plugin=tls \
--logger_tls_endpoint=/api/v1/osquery/log \
--logger_tls_period=10 &"



sudo mkdir -p $TSSL
cp $CA_LOC $SSL_CA

echo "$CMD_TEMPLATE" > $FHRUNNER
echo "$OSQUERY_SECRET" > $OSQUERY_SECRET_PATH

sudo chmod -R 600 $BASE
sudo chmod 700 $FHRUNNER

# create the system v service and run it at startup
sudo cp $ISERVICE $FSERVICE
sudo chmod 700 $FSERVICE
sudo chmod a+r $FSERVICE
sudo update-rc.d $SERVICE defaults
sudo update-rc.d $SERVICE enable

$FSERVICE start
