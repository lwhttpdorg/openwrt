#!/bin/sh
# Generate DTS patches from linux-main base (6.12 kernel)
# Requires in openwrt root: mt7986a-a.dtsi, mt7986a-b.dtsi, mt7986a-bananapi-bpi-r3-mini-a.dts, mt7986a-bananapi-bpi-r3-mini-b.dts

# 998: hnat node in mt7986a.dtsi (dtsi first, board dts includes it)
diff -u mt7986a-a.dtsi mt7986a-b.dtsi > mt7986a-dtsi.patch
sed -i '1,2d' mt7986a-dtsi.patch
sed -i '1i --- a/arch/arm64/boot/dts/mediatek/mt7986a.dtsi' mt7986a-dtsi.patch
sed -i '1a +++ b/arch/arm64/boot/dts/mediatek/mt7986a.dtsi' mt7986a-dtsi.patch
cp mt7986a-dtsi.patch target/linux/mediatek/patches-6.6/998-arm64-dts-mediatek-mt7986a-add-hnat-node.patch
rm mt7986a-dtsi.patch

# 999: thermal control in mt7986a-bananapi-bpi-r3-mini.dts
# diff -u target/linux/mediatek/dts/mt7986a-bananapi-bpi-r3-mini.dts mt7986a-bananapi-bpi-r3-mini.dts > bpi-r3-mini-dts.patch
# sed -i '1,2d' bpi-r3-mini-dts.patch
# sed -i '1i --- a/arch/arm64/boot/dts/mediatek/mt7986a-bananapi-bpi-r3-mini.dts' bpi-r3-mini-dts.patch
# sed -i '1a +++ b/arch/arm64/boot/dts/mediatek/mt7986a-bananapi-bpi-r3-mini.dts' bpi-r3-mini-dts.patch
# cp bpi-r3-mini-dts.patch target/linux/mediatek/patches-6.12/999-arm64-dts-mediatek-mt7986a-bpi-r3-mini-add-thermal-control.patch
# rm bpi-r3-mini-dts.patch
