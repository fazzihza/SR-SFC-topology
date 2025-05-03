# Gunakan image dasar Debian
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
    && rm -rf /var/lib/apt/lists/*

# Clone repository FRR
RUN git clone https://github.com/FRRouting/frr.git /frr

# Build FRR dengan sFlow
WORKDIR /frr
RUN ./bootstrap.sh && \
    ./configure --enable-sflow && \
    make && \
    make install

# Clean up
RUN rm -rf /frr

# Tentukan entry point untuk menjalankan FRR
CMD ["/usr/lib/frr/frr", "-d"]
