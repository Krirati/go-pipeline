#!/bin/sh
set -e

echo "Run unit test"
go test -race -covermode=atomic -coverprofile=coverage.out ./...