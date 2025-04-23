#!/bin/sh

#git pull
./scripts/feeds update -a
./scripts/feeds update -a

#GOLANG_MAKEFILE=./feeds/packages/lang/golang/golang/Makefile
#sed -i -e 's/GO_VERSION_MAJOR_MINOR:=[0-9]\+\.[0-9]\+/GO_VERSION_MAJOR_MINOR:=1.24/' $GOLANG_MAKEFILE
#sed -i -e 's/GO_VERSION_PATCH:=[0-9]\+/GO_VERSION_PATCH:=2/' $GOLANG_MAKEFILE
#sed -i -e 's/PKG_HASH:=[0-9a-f]\+/PKG_HASH:=9dc77ffadc16d837a1bf32d99c624cb4df0647cee7b119edd9e7b1bcc05f2e00/' $GOLANG_MAKEFILE

#git apply ./feeds.diff

rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

./scripts/feeds install -a
./scripts/feeds install -a

