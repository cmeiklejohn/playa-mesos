#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo ">>> Waiting for Marathon to initialize"
sleep 60

