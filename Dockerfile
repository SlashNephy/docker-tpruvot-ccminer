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

FROM nvidia/cuda:11.8.0-base-ubuntu20.04@sha256:81ba35e7357d342304efa7111e1dcdda843771147171cdc9efc1d8d32346ecc9
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
