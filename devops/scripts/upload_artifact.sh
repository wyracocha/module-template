#!/usr/bin/env bash

# Validate required parameters
if [ -z "$ARTIFACTORY_USER" ] || [ -z "$ARTIFACTORY_TOKEN" ] || [ -z "$ARTIFACTORY_URL" ] || [ -z "$ARTIFACTORY_REPO" ] || [ -z "$ARTIFACTORY_NAMESPACE" ] || [ -z "$ARTIFACTORY_MODULE_NAME" ] || [ -z "$ARTIFACTORY_MODULE_PROVIDER" ] || [ -z "$FILE_NAME" ]; then
  echo "One or more required parameters are not set."
  exit 1
fi

# Calculate checksum
CHECKSUM=$(shasum -a 1 $FILE_PATH/$FILE_NAME.zip | awk '{ print $1 }')

# Upload to Artifactory with retries
max_attempts=5
attempt=1
success=false

while [ $attempt -le $max_attempts ]; do
  echo "Attempt $attempt of $max_attempts"
  curl -s -S --retry 3 --retry-delay 5 --header "X-Checksum-Sha1:${CHECKSUM}" -u$ARTIFACTORY_USER:$ARTIFACTORY_TOKEN -XPUT "$ARTIFACTORY_URL/$ARTIFACTORY_REPO/$ARTIFACTORY_NAMESPACE/$ARTIFACTORY_MODULE_NAME/$ARTIFACTORY_MODULE_PROVIDER/$FILE_NAME.zip" -T $FILE_PATH/$FILE_NAME.zip

  if [ $? -eq 0 ]; then
    echo "Curl command succeeded."
    success=true
    break
  else
    echo "Curl command failed. Retrying..."
    ((attempt++))
    sleep 5
  fi
done

if [ $success = false ]; then
  echo "Curl command failed after $max_attempts attempts."
  exit 1
fi
