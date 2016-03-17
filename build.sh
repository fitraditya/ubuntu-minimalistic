#!/bin/bash

# Remove existing container and image
docker rm ubuntu-minimalistic
docker rmi fitra/ubuntu-minimalistic

set -ve

# Build base image
docker build -t fitra/ubuntu-minimalistic-multilayer - < Dockerfile.multilayer

# Create temp image file for storing cleaned up image
TEMP_FILE="`mktemp -t ubuntu-minimalistic-XXX.tar.gz`"

# Archive selected package inside images using temp image file
docker run --rm -i fitra/ubuntu-minimalistic-multilayer tar zpc \
  --exclude=/etc/hostname --exclude=/etc/resolv.conf \
  --exclude=/etc/hosts --one-file-system / > "$TEMP_FILE"

# Remove previous built image
docker rmi fitra/ubuntu-minimalistic-multilayer

# Create new image based on temp image file
docker import - fitra/ubuntu-minimalistic-nocmd < "$TEMP_FILE"

# Build final image
docker build -t fitra/ubuntu-minimalistic - < Dockerfile.nocmd

# Remove unused image and file
docker rmi fitra/ubuntu-minimalistic-nocmd
rm -f "$TEMP_FILE"
