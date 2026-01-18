#!/bin/bash
# JDCloud 雅典娜专用 - 精简DIY脚本 (已修复语法)
# 注意：不再克隆或清理插件，所有插件通过config文件管理

echo "========== 开始雅典娜固件自定义配置 =========="

# 应用补丁（如果有）
if [ -f "$GITHUB_WORKSPACE/scripts/011-fix-mbo-modules-build.patch" ]; then
    echo "应用 hostapd 补丁..."
    cp -f "$GITHUB_WORKSPACE/scripts/011-fix-mbo-modules-build.patch" package/network/services/hostapd/patches/
fi

# IPQ60XX内核优化
echo "优化IPQ60XX内核编译参数..."
sed -i 's/-Os/-O2/g' include/target.mk
if [ -f "target/linux/qualcommax/Makefile" ]; then
    sed -i 's/CPU_OPTIMIZATION = .*/CPU_OPTIMIZATION = -mcpu=cortex-a53+crypto -mtune=cortex-a53/g' target/linux/qualcommax/Makefile
fi

# 设置默认管理IP和主机名（可选）
# sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
# sed -i "s/hostname='OpenWrt'/hostname='Athena-Router'/g" package/base-files/files/bin/config_generate

# 修改版本信息 【关键修复行】
echo "修改版本标识..."
BUILD_DATE=$(date +%Y.%m.%d)
# 使用单引号包裹整个表达式，内部使用双引号，并对$符号进行转义
sed -i "s/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION=\"ImmortalWrt for JDCloud Athena \(Built on $BUILD_DATE\)\"/g" package/base-files/files/etc/openwrt_release

echo "========== 雅典娜自定义配置完成 =========="
