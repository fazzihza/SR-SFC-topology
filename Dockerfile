FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    protobuf-c-compiler \
    libprotobuf-c-dev \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libpcap-dev \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    iproute2 \
    iputils-ping \
    libprotobuf-dev \
    protobuf-compiler \
    bison \
    flex \
    libjson-c-dev \
    python3 \
    python3-dev \
    libelf-dev \
    curl \
    wget \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*





# Clone repository FRR
RUN git clone https://github.com/FRRouting/frr.git /frr

# Tentukan bekerja pada direktori frr
WORKDIR /frr
