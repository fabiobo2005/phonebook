#!/bin/bash

BUILD_VERSION=$(date | md5sum | awk '{print $1}')

echo "BUILD_VERSION=$BUILD_VERSION" > ./iac/.env

./gradlew clean build