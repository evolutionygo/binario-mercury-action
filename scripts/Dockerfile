FROM debian:bullseye AS premake-builder

RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y wget build-essential p7zip-full && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*

WORKDIR /usr/src
RUN set -eux; \
    wget -O premake.zip https://github.com/premake/premake-core/releases/download/v5.0.0-beta7/premake-5.0.0-beta7-src.zip; \
    7z x -y premake.zip; \
    PREMAKE_DIR="$(find . -maxdepth 1 -type d -name 'premake*' | head -n 1)"; \
    echo "Detected premake dir: ${PREMAKE_DIR}"; \
    test -n "${PREMAKE_DIR}"; \
    mv "${PREMAKE_DIR}" premake; \
    cd premake/build/gmake2.unix; \
    make -j"$(nproc)"

# Segunda etapa: Compilación de YGOPro con archivos modificados
FROM debian:bullseye AS ygopro-builder
LABEL Author="Nanahira <nanahira@momobako.com>"

RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y wget git build-essential libevent-dev libsqlite3-dev p7zip-full \
    python3 python-is-python3 liblua5.3-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=premake-builder /usr/src/premake/bin/release/premake5 /usr/bin/premake5

# Clonamos el repositorio base (Mycard/YGOPro)
WORKDIR /usr/src
RUN git clone --branch=server --recursive --depth=1 https://github.com/mycard/ygopro ygopro

# Compilación de YGOPro
WORKDIR /usr/src/ygopro
RUN git submodule foreach git checkout master && \
    premake5 gmake --lua-deb && \
    cd build && \
    make config=release -j$(nproc)

# Verificar contenido del binario antes de copiar
RUN echo "📂 Contenido de /usr/src/ygopro/bin/release/ antes de copiar:" && \
    ls -l /usr/src/ygopro/bin/release/

# Preparar la imagen final con el binario compilado
WORKDIR /usr/src/ygopro
RUN mkdir -p /build_output && \
    cp /usr/src/ygopro/bin/release/ygopro /build_output/ygopro && \
    strip /build_output/ygopro

# Verificar contenido de /build_output/
RUN echo "📂 Contenido de /build_output/ después de copiar:" && \
    ls -l /build_output/

# Imagen final con el binario listo
FROM debian:bullseye-slim AS final
LABEL Author="Nanahira <nanahira@momobako.com>"

RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y libevent-dev libsqlite3-dev liblua5.3-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Verificar que el binario está en la ubicación correcta antes de copiarlo
RUN ls -l /build_output/ || echo "❌ ERROR: Binario no encontrado en /build_output/"

COPY --from=ygopro-builder /build_output/ygopro /usr/bin/ygopro
RUN strip /usr/bin/ygopro

WORKDIR /data
ENTRYPOINT ["/usr/bin/ygopro"]


