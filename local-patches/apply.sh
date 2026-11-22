#!/bin/sh
# 把 local-patches/ 下的两处本地改动应用到当前仓库（幂等，可重复执行）
set -eu
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
cd "$repo"

apply() { # $1=补丁文件名 $2=已生效标记 $3=目标文件
	file="$3"
	if [ -f "$file" ] && grep -q -- "$2" "$file" 2>/dev/null; then
		echo "[skip ] $1  已在 $file 中生效"
		return 0
	fi
	if git apply --check -p1 "$here/$1" >/dev/null 2>&1; then
		git apply -p1 "$here/$1"
		echo "[apply] $1"
	elif patch -p1 --dry-run -s -l -f <"$here/$1" >/dev/null 2>&1; then
		patch -p1 -s -l -f <"$here/$1"
		echo "[apply] $1  （用 patch 命令，上下文有偏移）"
	else
		echo "[FAIL ] $1  无法自动应用，请手工改 $file" >&2
		echo "        参考补丁内容：$here/$1" >&2
		return 1
	fi
}

rc=0
apply 0001-qualcommax-ax3600-edma-disable-tso.patch \
	qcom,disable-tso \
	target/linux/qualcommax/dts/ipq8071-ax3600-stock.dts || rc=1
apply 0002-qualcommax-ax3600-ax6-disable-usb.patch \
	ssphy_1 \
	target/linux/qualcommax/dts/ipq8071-xiaomi.dtsi || rc=1

if [ "$rc" = 0 ]; then
	echo "--- 两处本地改动均已就位 ---"
else
	echo "--- 有补丁未能应用，按上面提示手工处理 ---" >&2
fi
exit "$rc"
#（注：内容由AI生成）
