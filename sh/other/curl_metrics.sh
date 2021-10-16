#!/bin/bash

url="http://www.google.com"

count=5
ms=450

time_total=()
time_namelookup=()

for (( count = 1; count <= 5; count++ )) ; do
  echo "loop $count"
  curl_output=$( curl -w "%{time_total} %{time_namelookup}" -o /dev/null -s "$url" )
  for item in $curl_output ; do
    echo " time: $item"
  done
  sleep ".$ms"
done
