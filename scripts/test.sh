#!/usr/bin/env bash

set -eou pipefail

EXIT_CODE=0

echo "Checking domains in config return 200s"
URLS=(
  "https://lts.lehigh.edu"
  "https%3A%2F%2Flts.lehigh.edu"
  "https://preserve.lehigh.edu"
  "https://$RANDOM.lib.lehigh.edu"
  "https://$RANDOM.$RANDOM.lib.lehigh.edu"

)
for URL in "${URLS[@]}"; do
  echo "Checking ${URL}"
  STATUS_CODE=$(curl -w '%{http_code}' \
    -o /dev/null \
    -s \
    "http://localhost:8888/proxyUrl?url=$URL")
  echo -e "\t${STATUS_CODE}"
  if [ ! "${STATUS_CODE}" -eq 200 ]; then
    EXIT_CODE=1
  fi
done

echo "Checking domains not in config throw 404s"
URLS=(
  "https://scholar.google.com"
  "https://$RANDOM.lehigh.edu"
  "https://$RANDOM.$RANDOM.lehigh.edu"
)
for URL in "${URLS[@]}"; do
  echo "Checking ${URL}"
  STATUS_CODE=$(curl -w '%{http_code}' \
    -o /dev/null \
    -s \
    "http://localhost:8888/proxyUrl?url=$URL")
  echo -e "\t${STATUS_CODE}"
  if [ "${STATUS_CODE}" -eq 200 ]; then
    EXIT_CODE=1
  fi
done

exit "${EXIT_CODE}"
