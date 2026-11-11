# openwrt-action-ct3003 · ImmortalWrt mt798x 自用固件

自用的 ImmortalWrt（mt798x 分支）GitHub Actions 编译仓库，主设备为 **Cetron CT3003**，同时附带 360T7、RAX3000M 的编译流水线。固件默认只有 IPv4、默认主题 Argon、代理统一用 PassWall2，成品发布在本仓库 [Releases](../../releases)。

> 已移除 24.10 支线（`padavanonly/immortalwrt-mt798x-24.10`，含原 ASR3000 流水线），本仓库现在只编译 **25.12**（`chasey-dev/immortalwrt-mt798x-rebase`，Linux 6.12 · GCC 14.3 · apk）。

## CT3003 固件概览

| 项目 | 说明 |
| --- | --- |
| 设备名称 | **Cetron CT3003**（MT7981 平台），编译目标 `CONFIG_TARGET_mediatek_filogic_DEVICE_cetron_ct3003-ubootmod` |
| 固件分支 | `chasey-dev/immortalwrt-mt798x-rebase` @ `25.12`，Linux 6.12 · GCC 14.3 · **apk** |
| 配置文件 | `config/ct3003-25.12.config` |
| 默认管理地址 | **192.168.10.1**，用户名 `root`，默认**空密码**（首次登录请立即设置） |
| 默认主题 | **Argon**（`jerrykuku/luci-theme-argon` + `luci-app-argon-config`）；`luci-theme-bootstrap` 也在固件内，可后台切换 |
| 默认网络 | 仅 IPv4：删 `wan6`、关 RA/DHCPv6、DNS 过滤 A/AAAA、`odhcpd` 不自启 |
| 主机名 | `ImmortalWrt`（改 hostname 的 sed 已注释） |
| 镜像 | 仅 squashfs（`CONFIG_TARGET_ROOTFS_SQUASHFS=y`，rootfs 分区 160 MB），`sysupgrade` 升级 |

> 产物是 `-ubootmod` 目标，走 U-Boot mod 分区布局，**与原厂 stock 分区固件不通用**；刷机前请先确认设备已处于 ubootmod 布局。

## 编译流水线

| Workflow | 源码 | 分支 | 配置文件 | 设备 target | 包管理 |
| --- | --- | --- | --- | --- | --- |
| `ct3003 25.12` | chasey-dev/immortalwrt-mt798x-rebase | `25.12` | `config/ct3003-25.12.config` | `cetron_ct3003-ubootmod` | apk |
| `360t7 25.12` | chasey-dev/immortalwrt-mt798x-rebase | `25.12` | `config/360t7-25.12.config` | `qihoo_360t7` | apk |
| `rax3000m 25.12` | chasey-dev/immortalwrt-mt798x-rebase | `25.12` | `config/rax3000m-25.12.config` | `cmcc_rax3000m` | apk |
| `Update Checker` | chasey-dev/immortalwrt-mt798x-rebase | `25.12` | — | 比对上游 commit 后 `repository_dispatch`（定时任务已注释，需手动运行） | — |

三条编译流水线共用 `sh/diy-part1.sh` 添加插件源、`sh/diy-part21.sh` 做定制。

## 已集成插件

**代理 / 分流**

- `sh/diy-part21.sh` 追加：`luci-app-passwall2` + `luci-i18n-passwall2-zh-cn`，内核带 `xray-core`、`sing-box`、`v2ray-geoip`、`v2ray-geosite`；OpenClash 已显式关闭

**主题**

- `luci-theme-argon` + `luci-app-argon-config`（默认）、`luci-theme-bootstrap`

**网络 / 路由增强**

- `luci-app-turboacc-mtk`（MTK 硬件加速）、`luci-app-eqos-mtk`（MTK 限速）、`luci-app-mtwifi-cfg`（MTK WiFi 配置）
- `luci-app-upnp` + `miniupnpd-nftables`
- `knot-resolver`（dnstap）DNS 组件

**家庭场景工具（三套 config 统一启用）**

| 插件 | 作用 | 说明 |
| --- | --- | --- |
| `luci-app-ddns` + `ddns-scripts` | 动态域名 | 宽带无固定公网 IP 时远程回家的前提 |
| `luci-app-wol` + `etherwake` | 网络唤醒 | 远程开启 NAS 或台式机 |
| `luci-proto-wireguard` + `kmod-wireguard` + `wireguard-tools` | WireGuard 远程接入 | |
| `luci-app-commands` | 网页执行命令 | 调试与脚本入口 |
| `luci-app-nlbwmon` + `nlbwmon` | 按设备统计流量 | |
| `luci-app-upnp` + `miniupnpd-nftables` | UPnP / NAT-PMP 端口映射 | |

以上插件均带 `luci-i18n-*-zh-cn` 中文语言包（i18n 符号依赖父包可见，故以显式 `CONFIG_PACKAGE_luci-i18n-*-zh-cn=y` 写入）。

> 未加 `luci-app-sqm`：本仓库用 MTK 的 `luci-app-eqos-mtk` 做限速，SQM 与它都改写 `tc` 规则，两套同时启用会互相覆盖、效果不稳定。确实需要 cake 算法压制缓冲膨胀时，先关 eQoS 再单独启用 SQM。

**运维 / 调试**

- `zram-swap`、`ethtool`、`tcpdump`、`iw`、`ubi-utils`、`uboot-envtools`
- 三套均带 `bash`、`nano`、`htop`、`unzip`、`curl`

**引导 / 固件工具**

- `u-boot-mt7981_cetron_ct3003`、`trusted-firmware-a-mt7981-*`、`fitblk`、`fit-check-sign`

> 配置里 `luci-app-passwall_INCLUDE_*` 这几项是上游模板残留，`luci-app-passwall` 主体包并未启用，不必按它判断固件里有 Passwall（实际装的是 Passwall2）。

## 定制点

均由 `sh/diy-part21.sh` 完成：

| 项目 | 内容 |
| --- | --- |
| 默认 IP | `192.168.1.1` → `192.168.10.1` |
| 代理 | 关闭 `luci-app-openclash`，追加 Passwall2 与内核 |
| 附加 | 克隆 `luci-app-adguardhome` 源码 |

默认主题的两处 `sed`（替换 `feeds/luci/collections/luci/Makefile` 里的 bootstrap）都是注释状态，Argon 实际由主题包自带的 `root/etc/uci-defaults/30_luci-theme-argon` 在首启写入 `luci.main.mediaurlbase=/luci-static/argon` 生效。

`diy-part21.sh` 还会注入一份首启脚本，把固件锁成纯 IPv4：

```sh
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
```

改默认 IP 时注意上游基线：25.12 上游 LAN 是 `192.168.1.1`，sed 目标写错会静默失效。

## 目录结构

```
.github/workflows/   ct3003-25.12.yml / 360t7-25.12.yml / rax3000m-25.12.yml / update-checker.yml
config/              三套 25.12 .config（设备 target 与插件清单都在这里）
sh/                  diy-part1.sh（插件源）/ diy-part21.sh（25.12 定制）
```

## 使用方法

1. Fork 仓库（或直接在本仓库操作，workflow 带 owner/sender 校验，只有仓库所有者能触发）。
2. 进入 **Actions**，选对应 workflow → **Run workflow**。
3. 编译完成后在 **Releases** 下载 `*squashfs-sysupgrade.bin`（或对应 `.itb`），按设备 U-Boot 刷入，勿跨分区布局刷。

> 自用固件，配置与插件组合按本人设备定制；换设备或换上游分支前，请同步核对 `config/*.config` 里的 `CONFIG_TARGET_*DEVICE_*` 与 DIY 脚本里的 IP/主题/插件段。
