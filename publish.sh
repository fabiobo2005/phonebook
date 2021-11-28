#!/bin/bash

echo $GITHUB_TOKEN | docker login -u $DOCKER_USERNAME ghcr.io --password-stdin
docker-compose -f ./iac/docker-compose.yml push