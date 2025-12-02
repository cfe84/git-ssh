#!/bin/sh

CONTAINER_NAME=gitssh
CONTAINER_IMAGE=gitssh
CONTAINER_PORT=22
EXPOSED_PORT=2222
FILES=/files/$CONTAINER_NAME
FILES_REPO=/mnt/storage/git
NETWORK=gitnet

mkdir -p $FILES/homessh
mkdir -p $FILES/serverkeys

echo "Events dir: $EVENTS_DIR"
echo "Repo root: $REPO_ROOT"

if [ -z "`docker network list | grep gitssh`" ]; then
  docker network create $CONTAINER_NAME --internal
fi
docker build / -t $CONTAINER_IMAGE -f Dockerfile \
  --build-arg EVENTS_DIR=$EVENTS_DIR \
  --build-arg REPO_ROOT=$REPO_ROOT

if [ $? -ne 0 ]; then
  echo "docker build failed - exiting"
  exit 1
fi

docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME
docker create \
	--name $CONTAINER_NAME \
	-p $EXPOSED_PORT:$CONTAINER_PORT \
  -v $FILES/homessh:/home/git/.ssh \
  -v $FILES/serverkeys:/etc/ssh \
  -v $FILES_REPO/public:/public \
  -v $FILES_REPO/private:/private \
  -v $FILES_REPO/events:/events \
	--user git \
	--restart unless-stopped \
	$CONTAINER_IMAGE
docker network connect $CONTAINER_NAME $CONTAINER_NAME

docker start $CONTAINER_NAME

