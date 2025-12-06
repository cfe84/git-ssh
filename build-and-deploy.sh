#!/bin/sh

CONTAINER_NAME=gitssh
CONTAINER_IMAGE=gitssh
CONTAINER_PORT=22
EXPOSED_PORT=2222
NETWORK=gitnet

if [ -z "$HOST_REPO_DIR" ]; then
  echo "HOST_REPO_DIR not set - it should point to where git files are stored on the host"
  exit 1
fi

if [ -z "$CONFIG_DIR" ]; then
  echo "CONFIG_DIR not set - it should point to where git config files are stored on the host"
  exit 1
fi

mkdir -p $CONFIG_DIR/homessh
mkdir -p $CONFIG_DIR/serverkeys

if [ -z "`docker network list | grep gitssh`" ]; then
  docker network create $CONTAINER_NAME --internal
fi
docker build / -t $CONTAINER_IMAGE -f Dockerfile \
  --build-arg EVENTS_DIR=/events \
  --build-arg REPO_ROOT=

if [ $? -ne 0 ]; then
  echo "docker build failed - exiting"
  exit 1
fi

docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME
docker create \
	--name $CONTAINER_NAME \
	-p $EXPOSED_PORT:$CONTAINER_PORT \
  -v $CONFIG_DIR/homessh:/home/git/.ssh \
  -v $CONFIG_DIR/serverkeys:/etc/ssh \
  -v $HOST_REPO_DIR/public:/public \
  -v $HOST_REPO_DIR/private:/private \
  -v $HOST_REPO_DIR/events:/events \
	--user git \
	--restart unless-stopped \
	$CONTAINER_IMAGE
docker network connect $CONTAINER_NAME $CONTAINER_NAME

docker start $CONTAINER_NAME

