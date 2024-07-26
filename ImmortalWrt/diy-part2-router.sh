#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

function config_del(){
    yes="CONFIG_$1=y"
    no="# CONFIG_$1 is not set"

    sed -i "s/$yes/$no/" .config
}

function config_add(){
    yes="CONFIG_$1=y"
    no="# CONFIG_$1 is not set"

    sed -i "s/${no}/${yes}/" .config

    if ! grep -q "$yes" .config; then
        echo "$yes" >> .config
    fi
}

function config_package_del(){
    package="PACKAGE_$1"
    config_del $package
}

function config_package_add(){
    package="PACKAGE_$1"
    config_add $package
}

function drop_package(){
    if [ "$1" != "golang" ];then
        # feeds/base -> package
        find package/ -follow -name $1 -not -path "package/custom/*" | xargs -rt rm -rf
        find feeds/ -follow -name $1 -not -path "feeds/base/custom/*" | xargs -rt rm -rf
    fi
}
function clean_packages(){
    path=$1
    dir=$(ls -l ${path} | awk '/^d/ {print $NF}')
    for item in ${dir}
        do
            drop_package ${item}
        done
}

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Modify default IP
sed -i 's/192.168.1.1/10.5.2.1/g' package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile


# 删除
# Sound Support
config_package_del kmod-sound-core
config_package_del kmod-ac97
config_package_del kmod-sound-hda-core
config_package_del kmod-sound-hda-codec-hdmi
config_package_del kmod-sound-hda-codec-realtek
config_package_del kmod-sound-hda-codec-via
config_package_del kmod-sound-hda-intel
config_package_del kmod-sound-i8x0
config_package_del kmod-sound-mpu401
config_package_del kmod-sound-via82xx
config_package_del kmod-usb-audio

# 新增
# luci
config_package_add luci
config_package_add default-settings-chn
# bbr
config_package_add kmod-tcp-bbr
# coremark cpu 跑分
config_package_add coremark
# autocore + lm-sensors-detect： cpu 频率、温度
config_package_add autocore
config_package_add lm-sensors-detect
# nano 替代 vim
config_package_add nano
# add upnp full
config_package_add luci-app-upnp
config_package_add libupnp
config_package_add miniupnpc
# tty 终端
config_package_add luci-app-ttyd
# docker -Del
## config_package_add luci-app-dockerman
# kms - Del
# config_package_add luci-app-vlmcsd
# usb 2.0 3.0 支持
config_package_add kmod-usb2
config_package_add kmod-usb3
# usb 网络支持
config_package_add usbmuxd
config_package_add usbutils
config_package_add usb-modeswitch
config_package_add kmod-usb-serial
config_package_add kmod-usb-serial-option
config_package_add kmod-usb-net-rndis
config_package_add kmod-usb-net-ipheth

# 第三方软件包
mkdir -p package/custom
git clone --depth 1  https://github.com/217heidai/OpenWrt-Packages.git package/custom
clean_packages package/custom
# golang
rm -rf feeds/packages/lang/golang
mv package/custom/golang feeds/packages/lang/
# argon 主题
config_package_add luci-theme-argon
## passwall
config_package_add luci-app-passwall
config_package_add luci-app-passwall_Nftables_Transparent_Proxy
config_package_del luci-app-passwall_Iptables_Transparent_Proxy
config_package_del luci-app-passwall_INCLUDE_Shadowsocks_Libev_Client
config_package_del luci-app-passwall_INCLUDE_Shadowsocks_Libev_Server
config_package_del luci-app-passwall_INCLUDE_Shadowsocks_Rust_Client
config_package_del luci-app-passwall_INCLUDE_Shadowsocks_Rust_Server
config_package_del luci-app-passwall_INCLUDE_ShadowsocksR_Libev_Client
config_package_del luci-app-passwall_INCLUDE_ShadowsocksR_Libev_Server
## 定时任务。重启、关机、重启网络、释放内存、系统清理、网络共享、关闭网络、自动检测断网重连、MWAN3负载均衡检测重连、自定义脚本等10多个功能
config_package_add luci-app-autotimeset
config_package_add luci-lib-ipkg
## 分区扩容。一键自动格式化分区、扩容、自动挂载插件，专为OPENWRT设计，简化OPENWRT在分区挂载上烦锁的操作
config_package_add luci-app-partexp
## iStore 应用市场 -Del
## config_package_add luci-app-store
## 4G/5G 支持：FM350-GL USB RNDIS
### Siriling/5G-Modem-Support
config_package_add luci-app-modem
config_package_add luci-app-sms-tool-js
### luci-app-modemband
config_package_add luci-app-modemband
### luci-app-3ginfo-lite
config_package_add luci-app-3ginfo-lite


# add mosdns
config_package_add luci-app-mosdns
config_package_add mosdns

# add turboacc  待恢复20240611测试不是此项影响-01
# config_package_add luci-app-turboacc
# config_package_add luci-app-turboacc
# config_package_add luci-app-turboacc_INCLUDE_OFFLOADING
# config_package_add luci-app-turboacc_INCLUDE_DNSFORWARDER
# config_package_add luci-app-turboacc_INCLUDE_DNSPROXY
# config_package_add luci-app-turboacc_INCLUDE_SHORTCUT_FE
# config_package_add luci-app-turboacc_INCLUDE_SHORTCUT_FE_CM

# add oc wg zt
config_package_add luci-app-wireguard
config_package_add luci-proto-wireguard
config_package_add wireguard-tools
config_package_add kmod-wireguard
config_package_add luci-app-zerotier
config_package_add luci-app-openclash

# ddns    待恢复20240611测试不是此项影响-02
#config_package_add ddns-scripts_aliyun
#config_package_add ddns-scripts_dnspod
#config_package_add luci-app-ddns
#config_package_add ddns-scripts
#config_package_add ddns-scripts-cloudflare
#config_package_add ddns-scripts-services
#config_package_add luci-i18n-ddns-zh-cn

# add nlbwmon   待恢复20240611测试不是此项影响-02
# config_package_add luci-app-nlbwmon
# config_package_add luci-i18n-nlbwmon-zh-cn
# config_package_add nlbwmon

# add network full 待恢复20240611测试不是此项影响-00
config_package_add dnsmasq-full
config_package_add dnsmasq_full_auth
config_package_add dnsmasq_full_conntrack
config_package_add CONFIG_PACKAGE_dnsmasq_full_dhcp
config_package_add nsmasq_full_dhcpv6
config_package_add dnsmasq_full_dnssec
config_package_add dnsmasq_full_ipset
config_package_add dnsmasq_full_noid
config_package_add dnsmasq_full_tftp
config_package_add haproxy
config_package_add ip-full
config_package_add ip6tables-extra
config_package_add ip6tables-mod-nat
config_package_add ipset
config_package_add iptables-mod-conntrack-extra
config_package_add iptables-mod-extra
config_package_add iptables-mod-iprange
config_package_add iptables-mod-ipsec
config_package_add iptables-mod-socket
config_package_add iptables-mod-tproxy
config_package_add iptables-nft
 config_package_add iputils-arping
# config_package_add kmod-button-hotplug is not set
config_package_add kmod-crypto-acompress
config_package_add kmod-crypto-aead
config_package_add kmod-crypto-authenc
config_package_add kmod-crypto-cbc
config_package_add kmod-crypto-deflate
config_package_add kmod-crypto-des
config_package_add kmod-crypto-echainiv
config_package_add kmod-crypto-hmac
config_package_add kmod-crypto-kpp
config_package_add kmod-crypto-lib-chacha20
config_package_add kmod-crypto-lib-chacha20poly1305
config_package_add kmod-crypto-lib-curve25519
config_package_add kmod-crypto-lib-poly1305
config_package_add kmod-crypto-manager
config_package_add kmod-crypto-md5
config_package_add kmod-crypto-null
config_package_add kmod-crypto-rng
config_package_add kmod-crypto-sha1
config_package_add kmod-crypto-sha256
config_package_add kmod-crypto-sha512
config_package_add kmod-dnsresolver
config_package_add kmod-fs-nfs
config_package_add kmod-fs-nfs-common
config_package_add kmod-fs-nfs-v3
config_package_add kmod-fs-nfs-v4
config_package_add kmod-fs-squashfs
config_package_add kmod-inet-diag
# config_package_add kmod-input-core is not set
config_package_add kmod-ip6tables
config_package_add kmod-ip6tables-extra
config_package_add kmod-ipsec
config_package_add kmod-ipsec4
config_package_add kmod-ipsec6
config_package_add kmod-ipt-conntrack
config_package_add kmod-ipt-conntrack-extra
config_package_add kmod-ipt-core
config_package_add kmod-ipt-extra
config_package_add kmod-ipt-iprange
config_package_add kmod-ipt-ipsec
config_package_add kmod-ipt-ipset
config_package_add kmod-ipt-nat
config_package_add kmod-ipt-nat6
config_package_add kmod-ipt-raw
config_package_add kmod-ipt-socket
config_package_add kmod-ipt-tproxy
config_package_add kmod-iptunnel
config_package_add kmod-iptunnel4
config_package_add kmod-iptunnel6
config_package_add kmod-lib-zlib-deflate
config_package_add kmod-lib-zlib-inflate
config_package_add kmod-nf-conntrack-netlink
config_package_add kmod-nf-ipt
config_package_add kmod-nf-ipt6
config_package_add kmod-nf-nat6
config_package_add kmod-nf-socket
config_package_add kmod-nft-compat
config_package_add kmod-nft-socket
config_package_add kmod-oid-registry
config_package_add kmod-sit
config_package_add kmod-tun
config_package_add kmod-udptunnel4
config_package_add kmod-udptunnel6


# 镜像生成
# 修改分区大小
sed -i "/CONFIG_TARGET_KERNEL_PARTSIZE/d" .config
echo "CONFIG_TARGET_KERNEL_PARTSIZE=32" >> .config
sed -i "/CONFIG_TARGET_ROOTFS_PARTSIZE/d" .config
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=2048" >> .config
# 调整 GRUB_TIMEOUT
sed -i "s/CONFIG_GRUB_TIMEOUT=\"3\"/CONFIG_GRUB_TIMEOUT=\"1\"/" .config
## 不生成 EXT4 硬盘格式镜像
config_del TARGET_ROOTFS_EXT4FS
## 不生成非 EFI 镜像
config_del GRUB_IMAGES
