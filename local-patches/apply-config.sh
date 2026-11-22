#!/bin/sh
# 在构建 .config 里关掉 AX3600/AX6 用不到的 USB 软件包（幂等）
# 用法：在仓库根目录、已经 make menuconfig / make defconfig 之后执行
#       ./local-patches/apply-config.sh
set -eu
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
cd "$repo"

CFG=.config
if [ ! -f "$CFG" ]; then
	echo "错误：仓库根目录没有 .config。先跑 make menuconfig 或 make defconfig，再来执行本脚本。" >&2
	exit 1
fi

SYMS="PACKAGE_kmod-usb3 \
PACKAGE_kmod-usb-dwc3 \
PACKAGE_kmod-usb-dwc3-qcom \
PACKAGE_kmod-usb-serial-qualcomm \
PACKAGE_kmod-usb-storage \
PACKAGE_automount"

changed=0
for s in $SYMS; do
	if [ -x ./scripts/config ]; then
		if grep -q "^CONFIG_$s=y" "$CFG" 2>/dev/null || ! grep -q "^# CONFIG_$s is not set" "$CFG" 2>/dev/null; then
			./scripts/config --file "$CFG" --disable "$s"
			echo "[disable] $s"
			changed=1
		else
			echo "[skip   ] $s 已是 n"
		fi
	else
		# 没有 scripts/config 时退化为 sed
		if grep -q "^CONFIG_$s=y" "$CFG" 2>/dev/null; then
			sed -i "/^CONFIG_$s=/d" "$CFG"
			printf '# CONFIG_%s is not set\n' "$s" >> "$CFG"
			echo "[disable] $s (sed)"
			changed=1
		elif grep -q "^# CONFIG_$s is not set" "$CFG" 2>/dev/null; then
			echo "[skip   ] $s 已是 n"
		else
			printf '# CONFIG_%s is not set\n' "$s" >> "$CFG"
			echo "[disable] $s (sed, 原本未定义)"
			changed=1
		fi
	fi
done

if [ "$changed" = 1 ]; then
	echo "--- 已修改 .config，正在 make olddefconfig 收敛依赖 ---"
	make olddefconfig >/dev/null 2>&1 || echo "（make olddefconfig 未执行成功，请手动跑一次）"
fi

echo "--- 当前状态 ---"
grep -E "^#? ?CONFIG_(PACKAGE_kmod-usb3|PACKAGE_kmod-usb-dwc3|PACKAGE_kmod-usb-dwc3-qcom|PACKAGE_kmod-usb-serial-qualcomm|PACKAGE_kmod-usb-storage|PACKAGE_automount)" "$CFG" || echo "（以上符号在 .config 中均未出现，说明依赖链已彻底断开）"
echo "--- 若某项又变成 =y，说明有别的包 select 了它，按名字继续往上关 ---"
#（注：内容由AI生成）
