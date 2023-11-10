FROM nvidia/cuda:11.8.0-devel-ubuntu20.04@sha256:594e37669bf42ae55fa2b4a06af4dcf9becc86045ab26a92c39bb93eb5781d0b AS build

RUN apt-get -y update \
    && apt-get -y install \
        build-essential \
        git \
        automake \
        libssl-dev \
        libcurl4-openssl-dev \
        libjansson-dev \
    \
    && git clone -b linux https://github.com/tpruvot/ccminer \
    && cd ccminer \
    && ./build.sh

FROM nvidia/cuda:11.8.0-base-ubuntu20.04@sha256:8803790082168d6fc95089288e8debb8e8318386658d10deb5c7175ec83b5e14
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES video,compute,utility
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/cuda-11.2/compat

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libcurl4 \
        libjansson4 \
        libgomp1 \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/*

COPY --from=build /ccminer/ccminer /

RUN adduser --disabled-password --gecos "" ccminer
USER ccminer

ENTRYPOINT [ "/ccminer" ]
