#!/usr/bin/env bash
set -euo pipefail

mkdir -p ./build

# Construir la imagen (último stage del Dockerfile)
docker build -t ygopro-builder -f scripts/Dockerfile .

# Crear contenedor (NO hace falta iniciarlo)
CID="$(docker create ygopro-builder)"

# Copiar binario al host
docker cp "$CID:/usr/bin/ygopro" ./build/ygopro

# Limpiar
docker rm -f "$CID" >/dev/null

# Validar y mostrar info útil
ls -la ./build
file ./build/ygopro
echo "✅ Binario copiado en ./build/ygopro"




