#!/bin/sh

# make diff of mt7986a.dtsi
# diff -u target/linux/mediatek/files-6.6/arch/arm64/boot/dts/mediatek/mt7986a.dtsi ./mt7986a.dtsi > ./999-dts-mt7986a-bpi-r3-mini.patch
diff -u mt7986a-orig.dtsi ./mt7986a.dtsi > ./999-dts-mt7986a-bpi-r3-mini.patch
# replace diff head
sed -i '1,2d' ./999-dts-mt7986a-bpi-r3-mini.patch
sed -i '1i --- a/arch/arm64/boot/dts/mediatek/mt7986a.dtsi' ./999-dts-mt7986a-bpi-r3-mini.patch
sed -i '1a +++ b/arch/arm64/boot/dts/mediatek/mt7986a.dtsi' ./999-dts-mt7986a-bpi-r3-mini.patch

# copy to patches directory
cp ./999-dts-mt7986a-bpi-r3-mini.patch target/linux/mediatek/patches-6.6/999-dts-mt7986a-bpi-r3-mini.patch
rm ./999-dts-mt7986a-bpi-r3-mini.patch
