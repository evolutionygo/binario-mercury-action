#!/bin/bash

docker build -t ygopro-builder -f scripts/Dockerfile .

docker create --name temp-container ygopro-builder

mkdir -p ./build

# Verificar archivos dentro del contenedor antes de copiarlos
echo "📂 Verificando archivos dentro del contenedor antes de copiar..."
docker start temp-container
docker exec temp-container ls -l /build_output/ || echo "⚠️ El directorio /build_output/ no existe en el contenedor"

# Intentar copiar el binario desde el contenedor
echo "🔄 Copiando el binario desde el contenedor..."
docker cp temp-container:/build_output/ygopro ./build/ygopro || echo "⚠️ No se pudo copiar el binario. Revisa /build_output/ dentro del contenedor."

docker rm temp-container

echo "✅ El binario ygopro se ha copiado a la carpeta ./build"
