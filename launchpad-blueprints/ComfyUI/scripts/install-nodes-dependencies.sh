#!/bin/bash

for dir in $PWD/custom_nodes/*/; do
 if [ -d "$dir" ]; then
  echo "Entering module: $dir"
  (cd "$dir" && pip install -qq -r requirements.txt)
 fi
done
