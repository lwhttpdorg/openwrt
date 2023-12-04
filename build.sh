#!/bin/sh
make download -j$(nproc) V=sc
make download -j$(nproc) V=sc
make -j$(nproc) V=sc

