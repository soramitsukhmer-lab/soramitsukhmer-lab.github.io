#!/usr/bin/env bash
set -e
export COMPOSE_PROJECT_NAME="consul"
COMPOSE_FILE="https://soramitsukhmer-lab.github.io/services/consul-agent/compose/$(uname)/compose.yml"
if [[ "$(uname)" == "Darwin" ]]; then
	export HOSTNAME; HOSTNAME=$(scutil --get LocalHostName)
else
	export HOSTNAME; HOSTNAME=$(hostname)
fi
(set -x; curl -s "$COMPOSE_FILE" | docker compose -f - up -d --pull always)
