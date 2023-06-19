FROM nvidia/cuda:11.8.0-devel-ubuntu20.04@sha256:91c743329ee61195221ff4ab84946b208a61092c4707be8ae33bded083c32d37 AS build

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

FROM nvidia/cuda:11.8.0-base-ubuntu20.04@sha256:425f0bdf5f09ef15c45ab61e6953c7ae7190b5e4e1203acae383edd5a0ac9941
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
