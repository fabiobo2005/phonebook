#!/bin/bash

# Check if the database is up and running.
while [ true ]; do
  nc -z database 3306

  if [ $? -eq 0 ]; then
    break
  else
    sleep 1
  fi
done

# Set debug and RASP environment variables.
export JPDA_OPTS="$JPDA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=0.0.0.0:8000"
export CATALINA_OPTS="$CATALINA_OPTS -javaagent:/home/user/lib/contrast.jar"

# Startup script in debug mode.
/opt/apache-tomcat/bin/catalina.sh jpda run