#!/bin/bash

echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME ghcr.io --password-stdin
docker-compose -f ./iac/docker-compose.yml push