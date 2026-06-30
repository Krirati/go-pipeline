#!/bin/sh
set -e

go test ./... \
  -coverprofile=coverage.out \
  -covermode=atomic \
  -v