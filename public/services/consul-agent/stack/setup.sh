#!/usr/bin/env bash
set -e
PLATFORM=$(uname)
DOCKER_SWARM_MODE=$(docker info --format '{{.Swarm.LocalNodeState}}')
if [[ "${DOCKER_SWARM_MODE}" == "inactive" ]]; then
	echo "ERR: Docker Swarm mode is not active. Please initialize Docker Swarm mode before running this setup script."
	exit 1
fi
if [[ "${PLATFORM}" == "Darwin" ]]; then
	export HOSTNAME; HOSTNAME=$(scutil --get LocalHostName)
else
	export HOSTNAME; HOSTNAME=$(hostname)
fi
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
