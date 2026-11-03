#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"

# 已按需求移除 openclash 源
# echo "src-git openclash https://github.com/vernesong/OpenClash.git;master" >> "feeds.conf.default"

# 新增 passwall2 源
echo "src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git" >> "feeds.conf.default"
echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall.git;packages" >> "feeds.conf.default"

# 主题
echo "src-git Argon https://github.com/jerrykuku/luci-theme-argon.git;master" >> "feeds.conf.default"
echo "src-git Argonconfig https://github.com/jerrykuku/luci-app-argon-config.git;master" >> "feeds.conf.default"
