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

# ===== 定制：固件默认仅 IPv4 =====
# 注入 uci-defaults 脚本，首次开机时删除 wan6、关闭 RA/DHCPv6、过滤 AAAA 记录、禁用 odhcpd 自启
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-default-ipv4 <<'EOF'
#!/bin/sh
uci -q delete network.wan6
uci -q commit network
uci -q set dhcp.lan.ra='disabled'
uci -q set dhcp.lan.dhcpv6='disabled'
uci -q set dhcp.lan.dnsmasq.filter_aaaa='1'
uci -q set dhcp.lan.dnsmasq.filter_a='1'
uci -q commit dhcp
/etc/init.d/odhcpd disable 2>/dev/null
exit 0
EOF
# ===== 定制结束 =====
