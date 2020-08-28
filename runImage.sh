#!/bin/bash

trap cleanup 1 2 3 6

cleanup()
{
  echo "Docker-Compose ... cleaning up."
  docker-compose -f ./docker-compose.yml down
  echo "Docker-Compose ... quitting."
  exit 1
}

set -e

docker-compose -f ./docker-compose.yml up --build 
