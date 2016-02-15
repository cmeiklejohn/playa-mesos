#!/usr/bin/env bash

# TODO: Maybe switch this to the Mesos-DNS docker container at some
# point instead of using the binary.
#
# docker run --net=host -d -v "/etc/mesos-dns/config.json:/config.json"
# mesosphere/mesos-dns /mesos-dns -config=/config.json

set -o errexit
set -o nounset
set -o pipefail

export BINARY=mesos-dns-v0.5.1-linux-amd64

echo ">>> Installing Mesos DNS"
mkdir -p /opt/mesos-dns
cd /opt/mesos-dns
wget https://github.com/mesosphere/mesos-dns/releases/download/v0.5.1/${BINARY}
mv ${BINARY} mesos-dns
chmod 755 mesos-dns

echo ">>> Configuring Mesos DNS"
cat <<EOF > config.json
{
  "zk": "zk://$IP:2181/mesos",
  "masters": ["$IP:5050"],
  "refreshSeconds": 60,
  "ttl": 60,
  "domain": "mesos",
  "port": 53,
  "resolvers": ["8.8.8.8"],
  "timeout": 5,
  "httpon": true,
  "dnson": true,
  "httpport": 8123,
  "externalon": true,
  "listener": "0.0.0.0",
  "SOAMname": "ns1.mesos",
  "SOARname": "root.ns1.mesos",
  "SOARefresh": 60,
  "SOARetry":   600,
  "SOAExpire":  86400,
  "SOAMinttl": 60,
  "IPSources": ["netinfo", "mesos", "host"]
}
EOF

cat <<EOF > mesos-dns.json
{
    "args": [
        "/mesos-dns",
        "-config=/config.json"
    ],
    "cpus": 0.1,
    "mem": 5.0,
    "id": "mesos-dns",
    "instances": 1,
    "container": {
      "type": "DOCKER",
      "docker": {
        "image": "mesosphere/mesos-dns",
        "network": "HOST",
        "forcePullImage": true
      },
      "volumes": [
          {
              "containerPath": "/config.json",
              "hostPath": "/opt/mesos-dns/config.json",
              "mode": "RO"
          }
      ]
    }
}
EOF

echo ">>> Adding Mesos DNS job to Marathon"
curl -H 'Content-type: application/json' -X POST -d @mesos-dns.json $MARATHON/v2/apps

echo ">>> Modifying local DNS to use Mesos DNS"
sed -i "1s/^/nameserver $IP\n /" /etc/resolv.conf
