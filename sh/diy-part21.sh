#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part21.sh
# Description: OpenWrt DIY script part 2 (After Update feeds) —— 25.12 分支使用
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

git clone -b main --single-branch --filter=blob:none https://github.com/sirpdboy/luci-app-adguardhome package/luci-app-adguardhome

# ===== 定制：移除 openclash =====
sed -i 's/^CONFIG_PACKAGE_luci-app-openclash=y/# CONFIG_PACKAGE_luci-app-openclash is not set/' .config

# ===== 定制：启用 passwall2 及常用内核组件 =====
cat >> .config <<'CFGEOF'
CONFIG_PACKAGE_luci-app-passwall2=y
CONFIG_PACKAGE_luci-i18n-passwall2-zh-cn=y
CONFIG_PACKAGE_xray-core=y
CONFIG_PACKAGE_sing-box=y
CONFIG_PACKAGE_v2ray-geoip=y
CONFIG_PACKAGE_v2ray-geosite=y
CFGEOF

#sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' feeds/packages/lang/rust/Makefile
