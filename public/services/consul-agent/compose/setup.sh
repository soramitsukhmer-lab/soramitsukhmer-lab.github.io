#!/usr/bin/env bash
set -e
PLATFORM=$(uname)
if [[ "${PLATFORM}" == "Darwin" ]]; then
	export HOSTNAME; HOSTNAME=$(scutil --get LocalHostName)
else
	export HOSTNAME; HOSTNAME=$(hostname)
fi
export COMPOSE_PROJECT_NAME="consul"
COMPOSE_FILE="https://soramitsukhmer-lab.github.io/services/consul-agent/compose/${PLATFORM}/compose.yml"
COMPOSE_FILE_OVERRIDE=""
if [ -f "compose.override.yml" ]; then
	COMPOSE_FILE_OVERRIDE="compose.override.yml"
elif [ -f "docker-compose.override.yml" ]; then
	COMPOSE_FILE_OVERRIDE="docker-compose.override.yml"
fi
if [ -n "$COMPOSE_FILE_OVERRIDE" ]; then
	echo "+ Found override file: $COMPOSE_FILE_OVERRIDE"
fi
(set -x; curl -s "$COMPOSE_FILE" | docker compose -f - ${COMPOSE_FILE_OVERRIDE:+-f "$COMPOSE_FILE_OVERRIDE"} up -d --pull always)
