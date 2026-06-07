FROM debian:trixie-slim

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/apt/sources.list && \
    sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources

RUN apt-get update && apt-get install -y --no-install-recommends \
    systemd \
    systemd-sysv \
    sudo \
    ca-certificates \
    && sed -i 's/http:\/\/mirrors.tuna.tsinghua.edu.cn/https:\/\/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN find /lib/systemd/system/sysinit.target.wants/ -insideonly \
    ! -name 'systemd-tmpfiles-setup.service' \
    -delete; \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN apt-get update && apt-get install -y --no-install-recommends \
    git vim \
    make gcc g++ rsync gawk unzip bzip2 wget python3 file \
    python3-pyelftools python3-setuptools swig python3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "root:12345678" | chpasswd

RUN useradd -m -s /bin/bash -G sudo dev && \
    echo "dev:12345678" | chpasswd && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/dev && \
    chmod 0440 /etc/sudoers.d/dev

CMD ["/lib/systemd/systemd"]

