## 说明
**本OpenWRT v22.03.5/v22.03.6 Fork [xYx-c/build-openwrt](https://github.com/xYx-c/build-openwrt)使用OpenWRT官方源码编译**

**OpenWRT v23.05（main）为缝合产物，搞了两天没搞定，因为同样的配置文件v23.05会编译错误。**

**下一步：稳定后，整合到ROOTFS这个repo里方便下载，并统一插件配置**

**仅适用于ARMv8的CPU，且只提供LXC所需的rootfs.**
  |名称|说明|用户|密码|
  |:----|:----|:----|:----|
  | IP| 10.5.2.1| root| password|

**用于x86_x64的的请到原作者处[xYx-c/build-openwrt/releases](https://github.com/xYx-c/build-openwrt/releases)下载.**

> **说明**:构建本openwrt目的是自己使用,没有太多功能比较清爽,仅仅适用我个人使用 - **附议原作者xYx-c，的确清爽**.

## 固件下载 [![](https://img.shields.io/badge/-编译状态及下载链接-FFFFFF.svg)](#固件下载-)
点击下表中 [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?style=flat&logo=hack-the-box)](https://github.com/518512/xYx-openwrt/releases) 即可跳转到该设备固件下载页面
| 平台+设备名称 | 固件编译状态 | 固件下载 |
| :-------------: | :-------------: | :-------------: |
| [![](https://img.shields.io/badge/OpenWrt-ArmV8_Mini_ROOTFS-32C955.svg?logo=openwrt)](#) |[![](https://github.com/518512/xYx-openwrt/actions/workflows/Build%20arm64.mini%20OpenWrt%20v22.03.6.yaml/badge.svg)](#) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/518512/xYx-openwrt/releases) |
| [![](https://img.shields.io/badge/OpenWrt-ArmV8_Mini_ROOTFS-32C955.svg?logo=openwrt)](#) |[![](https://github.com/518512/xYx-openwrt/actions/workflows/Build%20arm64.mini%20OpenWrt%20v23.05.3.yaml/badge.svg)](#) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/518512/xYx-openwrt/releases) |

### 构建openwrt或[releases](https://github.com/xYx-c/build-openwrt/releases)下载
- Fork本仓库-> Actions-> Build OpenWrt-> Run workflow

### pve8构建lxc openwrt容器
- 进入容器,执行命令:
```
pct create xxx \ # xxx容器序号
local:vztmpl/openwrt-xxx-rootfs.tar.gz \ # 镜像文件
--rootfs local:2 \ # 容器大小
--ostype unmanaged \
--hostname openwrt \
--arch amd64 \
--cores 4 \ # cpu
--memory 1024 \ # 内存
--swap 0  # 交换空间
```

- 配置文件路径
``` shell
vim /etc/pve/lxc/xxx.conf
```

- lxc追加配置
>   **注意**: 网卡配置的type, veth为虚拟网卡, phys为真实网卡
```
onboot: 0 # 是否开机启动 1是 0否
features: nesting=1
lxc.cgroup2.devices.allow: c 108:0 rwm
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.auto: proc:mixed sys:ro cgroup:mixed
lxc.mount.entry: /dev/net/tun dev/net/tun none rw,bind,create=file 0 0
lxc.mount.entry: /dev/ppp dev/ppp none rw,bind,optional,create=file 0 0
lxc.net.0.flags: up 
lxc.net.0.type: veth 
lxc.net.0.link: vmbr0 #虚拟网卡名
lxc.net.0.name: eth0
lxc.net.1.flags: up
lxc.net.1.type: phys
lxc.net.1.link: enp1s0 #真实网卡名
lxc.net.1.name: eth1
```

### 从lxc openwrt中dhcpv6服务获取ipv6
> pve启动后负责拨号的openwrt还未启动无法获取ipv6地址,添加定时任务系统启动3分钟后获取ipv6,每12小时重新尝试获取
- #### 创建dhcpv6.service
``` shell
cat >> /etc/systemd/system/dhcpv6.service << EOF
[Unit]
Description=OpenWrt DHCPv6 Server
After=network.target
[Service]
ExecStart=/usr/sbin/dhclient -6 vmbr0
[Install]
WantedBy=multi-user.target
EOF
```
- #### 创建dhcpv6.timer
``` shell
cat >> /etc/systemd/system/dhcpv6.timer << EOF
[Unit]
Description=OpenWrt DHCPv6 Server
After=network.target
[Timer]
OnBootSec=3min
OnUnitActiveSec=12h
[Install]
WantedBy=multi-user.target
EOF
```
- #### 运行定时任务
``` shell
systemctl daemon-reload
systemctl enable dhcpv6.timer
systemctl start dhcpv6.timer
```

### 网络配置
接口-> lan-> IPV6设置-> 本地IPV6-> **DNS服务器取消勾选**

### AdgHome DNS配置
- 重定向53端口到AdGuardHome
```
127.0.0.1:7874
# 防污染解析、
tls://dns.pub
https://dns.pub/dns-query
tls://dns.alidns.com
https://dns.alidns.com/dns-query
tls://dns.google.com
https://dns.google/dns-query
——————————————————
Bootstrap DNS
——————————————————
119.29.29.29
202.96.134.133
2402:4e00::
2400:3200::1
```

### OpenClash配置
插件设置-> DNS设置-> 停用*本地DNS劫持

#### 服务
  1. OpenClash
  2. AdguardHome
  3. DDNS
  4. ~~SmartDns~~

    5. MosDNS
    6. Agron主题
## 感谢

**[xYx-c/build-openwrt](https://github.com/xYx-c/build-openwrt) 、[Zane-E/ROOTFS](https://github.com/Zane-E/ROOTFS) 、[217heidai/OpenWrt-Builder](https://github.com/217heidai/OpenWrt-Builder) 、[db-one/OpenWrt-AutoBuild](https://github.com/db-one/OpenWrt-AutoBuild) 、[shidahuilang/openwrt](https://github.com/shidahuilang/openwrt) 、[haiibo/OpenWrt](https://github.com/haiibo/OpenWrt) [ophub/amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt) 等等无私的大神分享及教程**

## 鸣谢

- 感谢[openwrt源码](https://github.com/openwrt/openwrt) 、[LEDE源码](https://github.com/coolsnowwolf/lede) 、[ImmortalWrt源码](https://github.com/immortalwrt/immortalwrt)
- 感谢[@P3TERX](https://github.com/P3TERX)

> 使用了
>   1. [P3TERX大佬的云编译](https://github.com/P3TERX/Actions-OpenWrt)
>   2. 最后感谢上面使用了但未提及的大佬们

