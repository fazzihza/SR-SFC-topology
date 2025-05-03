FROM debian:bullseye-slim

# Install dependensi yang dibutuhkan untuk membangun FRR
RUN apt-get update && \
    apt-get install -y \
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
    libjson-c-dev && \
    rm -rf /var/lib/apt/lists/*



# Clone repository FRR
RUN git clone https://github.com/FRRouting/frr.git /frr

# Tentukan bekerja pada direktori frr
WORKDIR /frr
