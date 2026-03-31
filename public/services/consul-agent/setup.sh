#!/usr/bin/env bash
set -e
PLATFORM=$(uname)
DOCKER_SWARM_MODE=$(docker info --format '{{.Swarm.LocalNodeState}}')

if [[ "${PLATFORM}" == "Darwin" ]]; then
	export HOSTNAME; HOSTNAME=$(scutil --get LocalHostName)
else
	export HOSTNAME; HOSTNAME=$(hostname)
fi

# Evaluate the platform and swarm mode to determine which deployment method to use
# In swarm mode, use `docker stack deploy` with the appropriate stack file
# In non-swarm mode, use `docker compose up` with the appropriate compose file
if [[ "${DOCKER_SWARM_MODE}" == "active" ]]; then
	export DOCKER_STACK_NAME="consul"
	DOCKER_STACK_FILE="https://soramitsukhmer-lab.github.io/services/consul-agent/stack/${PLATFORM}/docker-stack.yml"
	DOCKER_STACK_FILE_OVERRIDE=""
	if [ -f "docker-stack.override.yml" ]; then
		DOCKER_STACK_FILE_OVERRIDE="docker-stack.override.yml"
	fi
	if [ -n "$DOCKER_STACK_FILE_OVERRIDE" ]; then
		echo "+ Found override file: $DOCKER_STACK_FILE_OVERRIDE"
	fi
	(set -x; curl -s "$DOCKER_STACK_FILE" | docker stack deploy -c - ${DOCKER_STACK_FILE_OVERRIDE:+-c "$DOCKER_STACK_FILE_OVERRIDE"} "$DOCKER_STACK_NAME")
else
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
fi
