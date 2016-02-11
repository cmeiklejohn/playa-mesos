#!/bin/sh

export MARATHON=http://10.141.141.10:8080

echo "Removing epmd from marathon..."
curl -H 'Content-type: application/json' -X DELETE $MARATHON/v2/apps/epmd
sleep 2

echo "Removing lasp from marathon..."
curl -H 'Content-type: application/json' -X DELETE $MARATHON/v2/apps/lasp
sleep 2

echo "Adding epmd to marathon..."
curl -H 'Content-type: application/json' -X POST -d @app_definitions/epmd.json $MARATHON/v2/apps
sleep 2

echo "Adding lasp to marathon..."
curl -H 'Content-type: application/json' -X POST -d @app_definitions/lasp.json $MARATHON/v2/apps
sleep 2
