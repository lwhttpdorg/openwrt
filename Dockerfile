FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

# Replace Debian default mirror with USTC mirror
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources

# Install required packages
RUN apt update && apt install -y \
    git sudo vim \
    make gcc g++ rsync gawk unzip bzip2 wget python3 file \
    python3-pyelftools python3-setuptools swig python3-dev \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Set root password
RUN echo "root:12345678" | chpasswd

# Create user 'build', add to sudo group, and set password
RUN useradd -m -s /bin/bash -G sudo build && \
    echo "build:12345678" | chpasswd && \
    echo "build ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
