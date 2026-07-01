#!/bin/sh
set -e

echo "Run unit test"
go test -covermode=atomic -coverprofile=coverage.out ./...