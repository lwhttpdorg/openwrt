#!/bin/sh

rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang

make download -j$(nproc) V=99
make download -j$(nproc) V=99
make -j$(nproc) V=99

