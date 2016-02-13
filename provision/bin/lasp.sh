#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export MARATHON=http://localhost:8080

echo ">>> Configuring Lasp"
cd /tmp

cat <<EOF > lasp.json
{
  "id": "lasp",
  "dependencies": [],
  "cpus": 0.2,
  "mem": 20.0,
  "instances": 1,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "cmeiklejohn/lasp-dev",
      "network": "BRIDGE",
      "portMappings": [
        { "containerPort": 8080, "hostPort": 0 }
      ],
      "forcePullImage": true
    }
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

echo ">>> Adding lasp to marathon"
curl -H 'Content-type: application/json' -X POST -d @lasp.json $MARATHON/v2/apps
echo
sleep 10
