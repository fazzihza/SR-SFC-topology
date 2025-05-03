FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    libtool \
    autoconf \
    automake \
    libreadline-dev \
    libjson-c-dev \
    protobuf-c-compiler \
    libprotobuf-c-dev \
    libsnmp-dev \
    libcap-dev \
    libelf-dev \
    python3 \
    python3-pip \
    pkg-config \
    flex \
    bison \
    libsystemd-dev \
    python3-dev \
    python3-sphinx \
    texinfo \
    libzmq3-dev \
    iproute2 \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Clone FRR source code
WORKDIR /frr
RUN git clone https://github.com/FRRouting/frr.git . && \
    ./bootstrap.sh && \
    ./configure \
        --enable-sflow \
        --enable-multipath=64 \
        --enable-user=frr \
        --enable-group=frr \
        --enable-vty-group=frrvty \
        --sysconfdir=/etc/frr \
        --localstatedir=/var/run/frr \
        --sbindir=/usr/lib/frr \
        --enable-systemd=no \
        && make -j$(nproc) && make install

# Copy default config files
RUN mkdir -p /etc/frr && \
    touch /etc/frr/daemons && \
    touch /etc/frr/frr.conf && \
    touch /etc/frr/vtysh.conf

ENV PATH="/usr/lib/frr:$PATH"

CMD ["/usr/lib/frr/zebra", "-d"]
