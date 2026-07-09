#!/bin/sh

rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang

# sed -i -e 's/GO_VERSION_MAJOR_MINOR:=[0-9]\+\.[0-9]\+/GO_VERSION_MAJOR_MINOR:=1.26/' ./feeds/packages/lang/golang/golang/Makefile
# sed -i -e 's/GO_VERSION_PATCH:=[0-9]\+/GO_VERSION_PATCH:=4/' ./feeds/packages/lang/golang/golang/Makefile
# sed -i -e 's/PKG_HASH:=[0-9a-f]\+/PKG_HASH:=4f668a32fbfc1132e6a881fb968c2f1dada631492a339211735fbb255a42602d/' ./feeds/packages/lang/golang/golang/Makefile

make download -j$(nproc) V=99
make download -j$(nproc) V=99
#GO111MODULE=on GOPROXY=https://goproxy.cn make -j$(nproc) V=99
make -j$(nproc) V=99
