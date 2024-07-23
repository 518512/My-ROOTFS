#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#


# Modify default IP
sed -i 's/192.168.1.1/10.5.2.1/g' package/base-files/files/bin/config_generate
 
# add custom packages
# echo 'src-git xYx https://github.com/xYx-c/openwrt-luci' >>feeds.conf.default

# openclash packages
git clone --depth=1 -b master https://github.com/vernesong/OpenClash.git package/openclash
mv openclash/luci-app-openclash package/luci-app-openclash && rm -rf openclash

git clone --depth=1 -b master https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

git clone --depth=1 -b main https://github.com/kingyond/luci-app-accesscontrol-plus package/accesscontrol-plus
mv accesscontrol-plus/luci-app-accesscontrol-plus  package/luci-app-accesscontrol-plus && rm -rf accesscontrol-plus

git clone --depth=1 -b master https://github.com/rufengsuixing/luci-app-zerotier package/luci-app-zerotier

#主题
# rm -rf feeds/luci/applications/luci-app-argon-config
# rm -rf feeds/kenzo/luci-app-argon-config
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# rm -rf feeds/luci/themes/luci-theme-argon
# rm -rf feeds/kenzo/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 20.x feeds/packages/lang/golang

#mosdns
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# update golang
# pushd feeds/packages/lang
# rm -rf golang && svn co https://github.com/openwrt/packages/trunk/lang/golang
# popd
