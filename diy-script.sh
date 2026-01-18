#!/bin/bash

# 1. 先添加所有需要的源，再删除冲突的
# 修改删除逻辑，避免误删
echo "开始清理冲突的包..."
# 只删除确实会冲突的包
rm -rf feeds/packages/net/mosdns 2>/dev/null || true
rm -rf feeds/packages/net/msd_lite 2>/dev/null || true
rm -rf feeds/packages/net/smartdns 2>/dev/null || true

# 2. 优化克隆逻辑，使用更稳定的源
function git_clone_fallback() {
  repo_url=$1
  repo_dir=$2
  branch=${3:-main}
  
  echo "正在克隆 $repo_dir..."
  if ! git clone --depth=1 -b $branch $repo_url $repo_dir 2>/dev/null; then
    echo "克隆失败，尝试使用备用源..."
    # 可以添加备用源逻辑
    return 1
  fi
  return 0
}

# 3. 添加IPQ60XX特定优化
# 复制设备树文件（如果需要）
if [ -d "$GITHUB_WORKSPACE/devices/ipq60xx" ]; then
    cp -rf $GITHUB_WORKSPACE/devices/ipq60xx/* package/
fi

# 4. 优化主题背景设置（确保文件存在）
if [ -f "$GITHUB_WORKSPACE/images/bg1.jpg" ]; then
    mkdir -p package/luci-theme-argon/htdocs/luci-static/argon/img/
    cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
fi

# 5. 增加编译优化
# 修改编译参数以优化IPQ60XX
sed -i 's/-Os/-O2/g' include/target.mk
sed -i 's/CPU_OPTIMIZATION = .*/CPU_OPTIMIZATION = -mcpu=cortex-a53+crypto/g' target/linux/qualcommax/Makefile

# 6. 修复可能的编译错误
# 添加IPQ60XX特定补丁
if [ -f "$GITHUB_WORKSPACE/patches/ipq60xx/*.patch" ]; then
    for patch in $GITHUB_WORKSPACE/patches/ipq60xx/*.patch; do
        patch -p1 < $patch
    done
fi
