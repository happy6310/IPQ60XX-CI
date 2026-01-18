#!/bin/bash
# 通用DIY脚本 - 支持多平台（雅典娜 & AX6000）
# 注意：不再克隆或清理插件，所有插件通过config文件管理

echo "========== 开始固件自定义配置 =========="

# === 1. 应用补丁（根据平台判断）===
echo "检查并应用补丁..."

# 1.1 只为高通平台（qualcommax）应用 hostapd 补丁
if [ -f "$GITHUB_WORKSPACE/scripts/011-fix-mbo-modules-build.patch" ]; then
    if [ -f "target/linux/qualcommax/Makefile" ]; then
        echo "检测到高通平台（雅典娜），应用 hostapd 补丁..."
        cp -f "$GITHUB_WORKSPACE/scripts/011-fix-mbo-modules-build.patch" package/network/services/hostapd/patches/
    else
        echo "检测到非高通平台（如AX6000的MTK），跳过 hostapd 补丁以避免兼容性问题。"
        # 可选：移除可能已存在的补丁文件，确保绝对干净
        rm -f package/network/services/hostapd/patches/011-fix-mbo-modules-build.patch 2>/dev/null || true
    fi
fi

# === 2. 平台特定的内核优化 ===
echo "进行平台特定的内核优化..."

# 2.1 高通平台优化 (IPQ60XX)
if [ -f "target/linux/qualcommax/Makefile" ]; then
    echo "检测到高通平台，应用IPQ60xx优化..."
    sed -i 's/-Os/-O2/g' include/target.mk
    sed -i 's/CPU_OPTIMIZATION = .*/CPU_OPTIMIZATION = -mcpu=cortex-a53+crypto -mtune=cortex-a53/g' target/linux/qualcommax/Makefile
fi

# 2.2 联发科平台优化 (MT7986)
if [ -f "target/linux/mediatek/Makefile" ]; then
    echo "检测到联发科平台（如AX6000），应用MT7986优化..."
    # 对于AX6000，保持-Os以优化体积，或根据需要改为-O2
    # sed -i 's/-Os/-O2/g' include/target.mk
    # 可以在此添加MTK平台特定的优化参数
fi

# === 3. 设置默认管理IP和主机名（可选） ===
# sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
# 可以根据平台设置不同的主机名
# if [ -f "target/linux/qualcommax/Makefile" ]; then
#     sed -i "s/hostname='OpenWrt'/hostname='Athena-Router'/g" package/base-files/files/bin/config_generate
# elif [ -f "target/linux/mediatek/Makefile" ]; then
#     sed -i "s/hostname='OpenWrt'/hostname='AX6000-Router'/g" package/base-files/files/bin/config_generate
# fi

# === 4. 修改版本信息 ===
echo "修改版本标识..."
BUILD_DATE=$(date +%Y.%m.%d)
# 通用版本信息，可根据平台进一步定制
sed -i "s/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION=\"ImmortalWrt Multi-Device Build ($BUILD_DATE)\"/g" package/base-files/files/etc/openwrt_release

echo "========== 固件自定义配置完成 =========="