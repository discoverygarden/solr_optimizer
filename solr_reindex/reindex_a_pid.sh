#!/bin/bash

MESSAGE="Re-indexing $4"
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" -u "$2:$3" "$1?operation=updateIndex&action=fromPid&value=$4")

if [ ! $HTTP_STATUS -eq 200  ]; then
  echo -e "ERROR $MESSAGE [HTTP status: $HTTP_STATUS]"
  exit 1
else
  echo -e "SUCCESS $MESSAGE [HTTP status: $HTTP_STATUS]"
  exit 0
fi
