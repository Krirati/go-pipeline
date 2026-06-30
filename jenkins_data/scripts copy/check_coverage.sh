#!/bin/sh
set -e

coverage=$(go tool cover -func=coverage.out \
  | awk '/total:/ {gsub("%","",$3); print $3}')

echo "Coverage = $coverage%"

awk -v c="$coverage" 'BEGIN {
  if (c < 80) {
    print "Coverage ต่ำกว่า 80%"
    exit 1
  }
}'