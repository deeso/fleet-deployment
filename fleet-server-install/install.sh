#!/bin/bash

source passwords.sh

DEFAULT_CONFIG="
mysql:
  address: 127.0.0.1:3306
  database: kolide
  username: root
  password: ${MYSQL_PASS}
redis:
  address: 127.0.0.1:6379
server:
  cert: /opt/fleet/ssl/fleetserver-cert.crt
  key: /opt/fleet/ssl/fleetserver-cert.key
  address: 0.0.0.0:443
auth:
  jwt_key: ${JWT_KEY}
logging:
  json: true
"

RUNNER=fleet-run.sh

ISERVICE=fleet-service.sh
SERVICE=fleet-service
FSERVICE=/etc/init.d/$SERVICE

MASTER_CONFIG=fleet.yaml
TARGET=/opt/fleet
TDATA=$TARGET/data/
TSSL=$TARGET/ssl/
TCONF=$TARGET/conf/
TCONF_FILE=$TCONF/fleet.yaml
FRUNNER=$TARGET/$RUNNER


if [ -n "$1"  ]
    then
      MASTER_CONFIG=$1
fi



LSSL_KEY=../ssl/fleetserver-cert.key
LSSL_CRT=../ssl/fleetserver-cert.crt
LSSL_CSR=../ssl/fleetserver-cert.csr

SSL_KEY=$TSSL/fleetserver-cert.key
SSL_CRT=$TSSL/fleetserver-cert.crt
SSL_CSR=$TSSL/fleetserver-cert.csr

GET_SSL=
if test -f "$LSSL_KEY" && test -f "$LSSL_CRT"; then
    echo "Found some local SSL files for install"
    echo "    $LSSL_KEY"
    echo "    $LSSL_CRT"
    GET_SSL="cp ../ssl/* $TSSL"
fi


if test -d "$TARGET"; then
    echo "Removing old files $TARGET"
    rm -rf $TARGET
fi

# it might be running?
/etc/init.d/fleet-service stop

# install the packages
sudo apt-get install unzip openssl redis-server mysql-server -y

# get fleet
wget --no-check-certificate https://github.com/kolide/fleet/releases/download/2.3.0/fleet.zip
unzip fleet.zip 'linux/*' -d tmp_fleet
sudo cp tmp_fleet/linux/fleet* /usr/bin/
rm -r tmp_fleet fleet.zip

# create target directories
mkdir -p $TDATA
mkdir -p $TCONF
mkdir -p $TSSL

if [ ! -z "$GET_SSL"  ]; then
    $GET_SSL
else
      sudo apt-get install openssl
      openssl genrsa -out $SSL_KEY 4096
      openssl req -new -key $SSL_KEY -out $SSL_CSR
      openssl x509 -req -days 366 -in $SSL_CSR -signkey $SSL_KEY -out $SSL_CRT
fi

# copy the supporting files
sudo cp $RUNNER $FRUNNER
if [ ! -f $MASTER_CONFIG ]; then
    echo "Initializiing fleet config (its missing)"
    # last poster, grrrr
    # https://stackoverflow.com/questions/40562595/creating-an-output-file-with-multi-line-script-using-echo-linux
    sudo echo "$DEFAULT_CONFIG" | sudo tee $TCONF_FILE > /dev/null
else
    sudo cp $MASTER_CONFIG $TCONF_FILE
  
fi

sudo chmod a+x $FRUNNER

# create the system v service and run it at startup
sudo cp $ISERVICE $FSERVICE
sudo chmod a+x $FSERVICE
sudo update-rc.d $SERVICE defaults
sudo update-rc.d $SERVICE enable

$FSERVICE start
