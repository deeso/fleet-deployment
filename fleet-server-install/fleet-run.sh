#!/bin/bash
FLEETBIN=/usr/bin/fleet
BASE=/opt/fleet/
CONF=$BASE/conf
CONF_FILE=$CONF/fleet.yaml
INIT_FILE=$BASE/fleet.initted

PREPARE_FLEET="$FLEETBIN prepare db --config $CONF_FILE"
SERVE_FLEET="$FLEETBIN serve --config $CONF_FILE"

if [ ! -f $INIT_FILE ]; then
    echo "Initializiing fleet"
    touch $INIT_FILE
    $PREPARE_FLEET
fi
 
echo "Starting fleet: $SERVE_FLEET"
$SERVE_FLEET &
