#!/bin/sh

#git pull
./scripts/feeds update -a
./scripts/feeds update -a

rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
#rm -rf feeds/packages/lang/golang
#git clone https://github.com/kenzok8/golang feeds/packages/lang/golang

#GOLANG_MAKEFILE=./feeds/packages/lang/golang/golang/Makefile
#sed -i -e 's/GO_VERSION_MAJOR_MINOR:=[0-9]\+\.[0-9]\+/GO_VERSION_MAJOR_MINOR:=1.20/' $GOLANG_MAKEFILE
#sed -i -e 's/GO_VERSION_PATCH:=[0-9]\+/GO_VERSION_PATCH:=10/' $GOLANG_MAKEFILE
#sed -i -e 's/PKG_HASH:=[0-9a-f]\+/PKG_HASH:=72d2f51805c47150066c103754c75fddb2c19d48c9219fa33d1e46696c841dbb/' $GOLANG_MAKEFILE

git apply ./feeds.diff

./scripts/feeds install -a
./scripts/feeds install -a

