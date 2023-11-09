#!/usr/bin/env bash

set -eou pipefail

if [ "$#" -eq 0 ] || [ ! -d "$1" ]; then
  echo "Need to pass the directory to EZProxy config to this script"
  exit 1
fi

DIR=$1
if [ ! -f "${DIR}/config.txt" ]; then
  echo "${DIR}/config.txt doesn't exist"
  exit 1
fi

FILES=()
while IFS='' read -r line; do FILES+=("$line"); done < <(grep "IncludeFile" "${DIR}/config.txt" | awk '{print $2}')
FILES+=("config.txt")

script_dir=$(dirname "$(readlink -f "$0")")
CONFIG_DIR="$script_dir/../config"
rm -f "${CONFIG_DIR}/*.txt"

for FILE in "${FILES[@]}"; do
  echo "${DIR}/$FILE"

  grep -Ei '^(U|URL) ' "${DIR}/$FILE" > u.txt
  if [ -s u.txt ]; then
    awk '{print $2}' u.txt | sort | uniq >> "${CONFIG_DIR}/urls.txt"
  fi

  grep -Ei '^(H|Host|HJ|HostJavascript) ' "${DIR}/$FILE" > h.txt || true
  if [ -s h.txt ]; then
    awk '{print $2}' h.txt | sed -E 's#^(https?://)?([^/]+).*#\2#' | sort | uniq >> "${CONFIG_DIR}/hosts.txt"
  fi

  grep -Ei '^(Domain|D|DJ|DomainJavascript) ' "${DIR}/$FILE" > d.txt || true
  if [ -s d.txt ]; then
    awk '{print $2}' d.txt | sort | uniq >> "${CONFIG_DIR}/domains.txt"
  fi
done

rm u.txt h.txt d.txt

RESULTS=( urls.txt hosts.txt domains.txt )
for RESULT in "${RESULTS[@]}"; do
  sed -E 's#^(https?://)?([^/]+).*#\2#' "${CONFIG_DIR}/${RESULT}" | sort | uniq > tmp
  mv tmp "${CONFIG_DIR}/${RESULT}"
done
