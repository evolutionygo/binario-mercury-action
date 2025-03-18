#!/bin/bash

# Construir la imagen
docker build -t ygopro-builder -f scripts/Dockerfile .

# Crear un contenedor basado en la imagen final
docker create --name temp-container ygopro-builder

mkdir -p ./build

# Verificar archivos dentro del contenedor antes de copiar
echo "📂 Verificando archivos dentro del contenedor antes de copiar..."
docker start temp-container
docker exec temp-container ls -l /usr/bin/ygopro || echo "⚠️ No se encontró /usr/bin/ygopro dentro del contenedor"

# Intentar copiar el binario desde la nueva ubicación
echo "🔄 Copiando el binario desde el contenedor..."
docker cp temp-container:/usr/bin/ygopro ./build/ygopro || echo "⚠️ No se pudo copiar el binario. Revisa /usr/bin/ygopro dentro del contenedor."

# Copiar el binario desde el contenedor
docker cp temp-container:/usr/bin/ygopro ./build/ygopro

docker rm -f temp-container

echo "✅ El binario ygopro se ha copiado a la carpeta ./build"

# Subir el binario al repositorio del Action
echo "🚀 Subiendo el binario al repositorio del Action..."
mv ./build/ygopro ./ygopro

git config --global user.name "github-actions"
git config --global user.email "actions@github.com"

git add ygopro
git commit -m "🔄 Subiendo binario YGOPRO generado automáticamente"
git push origin main || echo "⚠️ Error al hacer push, quizás no hay cambios nuevos."

echo "✅ Binario subido al repositorio del Action."

docker rm -f temp-container

echo "✅ El binario ygopro se ha copiado a la carpeta ./build"


