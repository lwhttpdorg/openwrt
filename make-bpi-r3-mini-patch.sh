#!/bin/sh

# # make diff of mt7986a.dtsi
# diff -u target/linux/mediatek/files-5.15/arch/arm64/boot/dts/mediatek/mt7986a.dtsi ./mt7986a.dtsi > ./mt7986a.patch
# # replace diff head
# sed -i '1,2d' ./mt7986a.patch
# sed -i '1i --- a/arch/arm64/boot/dts/mediatek/mt7986a.dtsi' ./mt7986a.patch
# sed -i '1a +++ b/arch/arm64/boot/dts/mediatek/mt7986a.dtsi' ./mt7986a.patch


# make diff of mt7986a-bananapi-bpi-r3-mini.dts
diff -Nua /dev/null mt7986a-bananapi-bpi-r3-mini.dts > ./mt7986a-bananapi-bpi-r3-mini.patch
# replace diff head
sed -i '1,2d' ./mt7986a-bananapi-bpi-r3-mini.patch
sed -i '1i --- a/dev/null' ./mt7986a-bananapi-bpi-r3-mini.patch
sed -i '1a +++ b/arch/arm64/boot/dts/mediatek/mt7986a-bananapi-bpi-r3-mini.dts' ./mt7986a-bananapi-bpi-r3-mini.patch

# merge diff
# cat ./mt7986a.patch > ./999-dts-mt7986a-bpi-r3-mini.patch
cat ./mt7986a-bananapi-bpi-r3-mini.patch >> ./999-dts-mt7986a-bpi-r3-mini.patch
# rm ./mt7986a.patch
rm ./mt7986a-bananapi-bpi-r3-mini.patch

# copy to patches directory
cp ./999-dts-mt7986a-bpi-r3-mini.patch target/linux/mediatek/patches-5.15/999-dts-mt7986a-bpi-r3-mini.patch
rm ./999-dts-mt7986a-bpi-r3-mini.patch
