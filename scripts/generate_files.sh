#!/usr/bin/env bash

set -eou pipefail

DIR=$1
FILES=("config.txt")
FILES+=($(grep IncludeFile $DIR/config.txt | awk '{print $2}'))

rm -f urls.txt hosts.txt domains.txt wildcard.txt
for FILE in "${FILES[@]}"; do
  echo "$DIR/$FILE"
  grep -i ^U $DIR/config.txt \
  | grep -v "Form=post " \
  | awk '{print $2}' \
  | sort | uniq \
  | awk -F '/' '{print $1,"//",$3}' | sed 's/ //g' \
  >> urls.txt

  grep -i ^H $DIR/config.txt \
  | awk '{print $2}' \
  | sort | uniq \
  >> hosts.txt

  egrep -i '^(Domain|D|DJ|DomainJavascript) ' $DIR/config.txt \
  | awk '{print $2}' \
  | sort | uniq \
  >> domains.txt

done

RESULTS=( urls.txt hosts.txt domains.txt )
for RESULT in "${RESULTS[@]}"; do
  sort $RESULT | uniq > tmp
  mv tmp config/$RESULT
  rm $RESULT
done
