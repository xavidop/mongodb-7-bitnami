#!/bin/bash

CONTAINER_REGISTRY=$1
IMAGE_NAME=$2

docker buildx create --name amd64
docker buildx use amd64
docker buildx inspect --bootstrap

# from tags-info.yaml
VERSION="latest"
VERSION_MAJOR="7.0"
VERSION_MINOR="7.0.14"
VERSION_OS="7.0-debian-12"

docker buildx build . -f Dockerfile -t $CONTAINER_REGISTRY/$IMAGE_NAME:$VERSION -t $CONTAINER_REGISTRY/$IMAGE_NAME:$VERSION_MAJOR -t $CONTAINER_REGISTRY/$IMAGE_NAME:$VERSION_MINOR -t $CONTAINER_REGISTRY/$IMAGE_NAME:$VERSION_OS --push -o type=image --platform=linux/arm64,linux/amd64
