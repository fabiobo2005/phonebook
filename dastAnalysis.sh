#!/bin/bash

# Check if the servers are up and running.
echo "Checking if the cluster manager is up and running..."
while [ true ]; do
  HTTP_STATUS_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null http://cluster-manager.$CLOUDFLARE_ZONE_NAME:30080)

  if [ $HTTP_STATUS_CODE == 200 ] || [ $HTTP_STATUS_CODE == 301 ] || [ $HTTP_STATUS_CODE == 302 ]; then
    break
  else
    sleep 1
  fi
done

echo "Checking if the cluster worker is up and running..."
while [ true ]; do
  HTTP_STATUS_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null http://cluster-worker.$CLOUDFLARE_ZONE_NAME:30080)

  if [ $HTTP_STATUS_CODE == 200 ] || [ $HTTP_STATUS_CODE == 301 ] || [ $HTTP_STATUS_CODE == 302 ]; then
    break
  else
    sleep 1
  fi
done

echo "Starting DAST Analysis..."

# Check the cluster manager.
HTTP_STATUS_CODE=$(curl -X POST -o /dev/null -s -w "%{http_code}\n" http://cluster-manager.$CLOUDFLARE_ZONE_NAME:30080/search?q=%3Cscript%3Ealert%281%29%3C%2Fscript%3E)

if [ $HTTP_STATUS_CODE != 500 ] && [ $HTTP_STATUS_CODE != 403 ]; then
  echo "DAST Analysis failed! The requests are not protected against XSS (Cross Site Scripting) attacks."

  exit 1
fi

# Check the cluster worker.
HTTP_STATUS_CODE=$(curl -X POST -o /dev/null -s -w "%{http_code}\n" http://cluster-worker.$CLOUDFLARE_ZONE_NAME:30080/search?q=%3Cscript%3Ealert%281%29%3C%2Fscript%3E)

if [ $HTTP_STATUS_CODE != 500 ] && [ $HTTP_STATUS_CODE != 403 ]; then
  echo "DAST Analysis failed! The requests are not protected against XSS (Cross Site Scripting) attacks."

  exit 1
fi

echo "DAST Analysis passed! Good work!"

exit 0
