#!/bin/sh

# make diff of mt7986a.dtsi
# diff -u target/linux/mediatek/files-6.6/arch/arm64/boot/dts/mediatek/mt7986a.dtsi ./mt7986a.dtsi > ./mt7986a-dtsi.patch
diff -u mt7986a-orig.dtsi ./mt7986a.dtsi > ./mt7986a-dtsi.patch
# replace diff head
sed -i '1,2d' ./mt7986a-dtsi.patch
sed -i '1i --- a/arch/arm64/boot/dts/mediatek/mt7986a.dtsi' ./mt7986a-dtsi.patch
sed -i '1a +++ b/arch/arm64/boot/dts/mediatek/mt7986a.dtsi' ./mt7986a-dtsi.patch

diff -u mt7986a-bananapi-bpi-r3-mini-orig.dts mt7986a-bananapi-bpi-r3-mini.dts > ./bpi-r3-mini-dts.patch
# replace diff head
sed -i '1,2d' ./bpi-r3-mini-dts.patch
sed -i '1i --- a/arch/arm/dts/mt7986a-bananapi-bpi-r3-mini.dts' ./bpi-r3-mini-dts.patch
sed -i '1a +++ b/arch/arm/dts/mt7986a-bananapi-bpi-r3-mini.dts' ./bpi-r3-mini-dts.patch

# combine both patches
cat ./mt7986a-dtsi.patch ./bpi-r3-mini-dts.patch > ./999-dts-mt7986a-bpi-r3-mini.patch
# clean up
rm ./mt7986a-dtsi.patch
rm ./bpi-r3-mini-dts.patch

# copy to patches directory
cp ./999-dts-mt7986a-bpi-r3-mini.patch target/linux/mediatek/patches-6.6/999-dts-mt7986a-bpi-r3-mini.patch
#rm ./999-dts-mt7986a-bpi-r3-mini.patch
