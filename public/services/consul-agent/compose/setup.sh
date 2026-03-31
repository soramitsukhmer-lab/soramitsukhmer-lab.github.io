#!/usr/bin/env bash
set -e
COMPOSE_FILE="https://soramitsukhmer-lab.github.io/services/consul-agent/compose/$(uname)/compose.yml"

if [[ "$(uname)" == "Darwin" ]]; then
  export HOSTNAME; HOSTNAME=$(scutil --get LocalHostName)
else
  export HOSTNAME; HOSTNAME=$(hostname)
fi

export COMPOSE_PROJECT_NAME="consul"
export CONSUL_ADVERTISE_ADDRESS; CONSUL_ADVERTISE_ADDRESS=$(curl -s http://myip.sorakh.run)

(set -x; curl -s "$COMPOSE_FILE" | docker compose -f - up -d)
