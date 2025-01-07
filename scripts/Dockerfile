FROM debian:bullseye AS premake-builder

RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y wget build-essential p7zip-full && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*

WORKDIR /usr/src
RUN wget -O premake.zip https://github.com/premake/premake-core/releases/download/v5.0.0-beta1/premake-5.0.0-beta1-src.zip && \
    7z x -y premake.zip && \
    mv premake-5.0.0-beta1-src premake && \
    cd premake/build/gmake2.unix && \
    make -j$(nproc)

FROM debian:bullseye AS ygopro-builder
LABEL Author="Nanahira <nanahira@momobako.com>"

RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y wget git build-essential libevent-dev libsqlite3-dev p7zip-full python3 python-is-python3 liblua5.3-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=premake-builder /usr/src/premake/bin/release/premake5 /usr/bin/premake5

RUN git clone --branch=server --recursive --depth=1 https://github.com/termitaklk/ygopro-evolution-bin && \
    cd ygopro-evolution-bin && \
    git submodule foreach git checkout master && \
    premake5 gmake --lua-deb && \
    cd build && \
    make config=release -j$(nproc) && \
    cd .. && \
    mkdir -p /build_output && \
    mv ./bin/release/ygopro /build_output/ygopro && \
    strip /build_output/ygopro && \
    mkdir replay expansions && \
    rm -rf .git* bin obj build ocgcore cmake lua premake* sound textures .travis.yml *.txt appveyor.yml LICENSE README.md *.lua strings.conf system.conf && \
    ls gframe | sed '/game.cpp/d' | xargs -I {} rm -rf gframe/{}
