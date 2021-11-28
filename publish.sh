#!/bin/bash

echo $DOCKER_REGISTRY_PASSWORD | docker login -u $DOCKER_REGISTRY_USER ghcr.io --password-stdin
docker-compose -f ./iac/docker-compose.yml push