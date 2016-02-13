#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export MARATHON=http://localhost:8080

echo ">>> Configuring epmd"
cd /tmp

cat <<EOF > epmd.json
{
  "id": "epmd",
  "cpus": 0.2,
  "mem": 20.0,
  "instances": 1,
  "constraints": [["hostname", "UNIQUE", ""]],
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "cmeiklejohn/epmd",
      "network": "HOST",
      "forcePullImage": true
    }
  }
}
EOF

echo ">>> Adding epmd to marathon"
curl -H 'Content-type: application/json' -X POST -d @epmd.json $MARATHON/v2/apps
echo
sleep 10

echo ">>> Waiting for epmd to initialize"
sleep 60
