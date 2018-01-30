#!/bin/bash
# sh install.sh -host fleet.internal.thecoverofnight.com \
# -crt https://gist.githubusercontent.com/deeso/1234/raw/1234/fleetserver-ca.crt \
# -secret s3kr3t
USAGE="Usage: `basename $0` -help | -host [host] -ca [HTTP_LOC_CERT] -secret [OSQUERY_SECRET]"
OSQUERY=/usr/bin/osqueryd

RSYSLOG_PATH=/etc/rsyslog.conf

BASE=/etc/osquery
OSQUERY_SECRET_PATH=$BASE/secret.txt
TSSL=$BASE/ssl
SSL_CA=$TSSL/fleetserver-ca.crt
TMP_CA=/tmp/fleetserver-ca.crt

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



ADDL_FLAGS="--host_identifier=uuid
--enroll_tls_endpoint=/api/v1/osquery/enroll
--config_plugin=tls
--config_tls_endpoint=/api/v1/osquery/config
--config_tls_refresh=10
--disable_distributed=false
--distributed_plugin=tls
--distributed_interval=10
--distributed_tls_max_attempts=3
--distributed_tls_read_endpoint=/api/v1/osquery/distributed/read
--distributed_tls_write_endpoint=/api/v1/osquery/distributed/write
--logger_plugin=tls
--logger_tls_endpoint=/api/v1/osquery/log
--logger_tls_period=10
--enroll_secret_path=$OSQUERY_SECRET_PATH
--tls_server_certs=$SSL_CA
--tls_hostname=$TLS_HOST"

git clone https://github.com/palantir/osquery-configuration.git
echo "$ADDL_FLAGS" >> osquery-configuration/Servers/Linux/osquery.flags 
sudo cp -R osquery-configuration/Servers/Linux/* /etc/osquery
rm -rf osquery-configuration

sudo mkdir -p $TSSL
sudo cp $CA_LOC $SSL_CA
sudo chmod -R a+r $TSSL


echo "$OSQUERY_SECRET" | sudo tee $OSQUERY_SECRET_PATH > /dev/null

sudo chmod -R 600 $OSQUERY_SECRET_PATH

# from digital ocean post on ubuntu osquery-configuration
DO_RSYSLOG_APPEND='
template(
  name="OsqueryCsvFormat"
    type="string"
      string="%timestamp:::date-rfc3339,csv%,%hostname:::csv%,%syslogseverity:::csv%,%syslogfacility-text:::csv%,%syslogtag:::csv%,%msg:::csv%\n"

)
*.* action(type="ompipe" Pipe="/var/osquery/syslog_pipe" template="OsqueryCsvFormat")
'

HAS_RSYSLOG_MOD=$(cat $RSYSLOG_PATH | grep "OsqueryCsvFormat")
if [ -z "$VAR"  ]; then
    echo "$DO_RSYSLOG_APPEND" | sudo tee --append $RSYSLOG_PATH > /dev/null
    sudo etc/init.d/rsyslog restart
fi


sudo osqueryctl start
