FROM nvidia/cuda:12.6.2-devel-ubuntu20.04@sha256:4530850d4ab58f12b611da7bcceb7f4402f94e16b773c7c4b5358941ddea7e32 AS build

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

FROM nvidia/cuda:12.6.2-base-ubuntu20.04@sha256:ec18669e4c5a9eef8d131adc26475ceb3400ecb475dfd44309564852695a810b
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
