#!/bin/sh
set -e

echo "Run unit test"
go test ./... \
  -coverprofile=coverage.out \
  -covermode=atomic \
  -v