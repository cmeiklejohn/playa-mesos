#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo ">>> Configuring Lasp"
cd /tmp

cat <<EOF > lasp.json
{
  "id": "lasp",
  "dependencies": [],
  "cpus": 0.1,
  "mem": 5.0,
  "instances": 1,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "cmeiklejohn/lasp-dev",
      "network": "HOST",
      "forcePullImage": true
    }
  },
  "env": {
    "IP": "$IP"
  },
  "healthChecks": [
    {
      "path": "/api/health",
      "portIndex": 0,
      "protocol": "HTTP",
      "gracePeriodSeconds": 300,
      "intervalSeconds": 60,
      "timeoutSeconds": 20,
      "maxConsecutiveFailures": 3,
      "ignoreHttp1xx": false
    }
  ]
}
EOF

echo ">>> Removing lasp from Marathon"
curl -H 'Content-type: application/json' -X DELETE $MARATHON/v2/apps/lasp
sleep 2

echo ">>> Adding lasp to Marathon"
curl -H 'Content-type: application/json' -X POST -d @lasp.json $MARATHON/v2/apps
echo
sleep 10
