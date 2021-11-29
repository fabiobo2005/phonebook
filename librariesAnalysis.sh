#!/bin/bash
wget https://github.com/snyk/snyk/releases/download/v1.530.0/snyk-linux; mv ./snyk-linux ./snyk; chmod +x ./snyk;

SNYK_CMD=`which snyk`

if [ -z "$SNYK_CMD" ]; then
  SNYK_CMD=./snyk
fi

$SNYK_CMD test backend --severity-threshold=high
