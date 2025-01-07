#!/bin/bash

docker build -t ygopro-builder -f scripts/Dockerfile .

docker create --name temp-container ygopro-builder

mkdir -p ./build

docker cp temp-container:/build_output/ygopro ./build/ygopro

docker rm temp-container

echo "El binario ygopro se ha copiado a la carpeta ./build"