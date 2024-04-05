# OpenWrt项目

![OpenWrt logo](https://openwrt.org/_media/logo.png "OpenWrt")

这个项目fork自[OpenWrt](https://github.com/openwrt/openwrt)

默认登录地址: <http://172.16.0.1>, 用户名: __root__, 密码: 无.

## 1. 如何编译自己需要的 OpenWrt 固件

### 1.1. 快速开始

1. 执行命令 `git clone -b <branch> --single-branch https://github.com/SandroDickens/openwrt.git` 下载源码.
2. 执行命令 `cd openwrt` 进入源码目录.
3. 执行命令 `./scripts/feeds update -a` 获取feeds.conf / feeds.conf.default中定义的最新的包.
4. 执行命令 `./scripts/feeds install -a` to install symlinks for all obtained packages into package/feeds/
5. 执行命令 `make menuconfig` 选择你需要的toolchain, target system和firmware包生成配置文件.
6. 执行命令 `make download -j$(nproc) V=sc` 下载源码、交叉编译工具链、Linux内核等(需要能访问国际互联网, 此过程可能会有部分文件下载失败,
   为保守起见最好执行2遍).
7. 执行命令 `make -j$(nproc) V=sc` 编译固件.

### 1.2 部分设备配置文件

部分设备有经过验证的配置文件:

* [BananaPi R3 mini](config-bpi-r3-mini-emmc): emmc版本, 可识别整个8G emmc. 含NAT加速, 含温控调速

* [BananaPi R3 mini(nand)](config-bpi-r3-mini-nand): NAND Flash版本. 含NAT加速, 含温控调速

* [x86_64](config-x86): i225/i226网卡

* [红米AC2100](config-ac2100)

* [NanoPi R2S](config-r2s): WAN, LAN互换. 包含了uqmi, 包含PWM风扇温控调速

* [NanoPi R4S](config-r4s): 很久未验证了

## 2. 许可

OpenWrt is licensed under [GPL-3.0-only](https://spdx.org/licenses/GPL-3.0-only.html).
