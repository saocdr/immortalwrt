# local-patches：AX3600 / AX6 的本地 DTS 改动

## 为什么不是放进 patches-6.18/

`target/linux/qualcommax/dts/*.dts` 不是在构建里被拷进内核源码树的，而是由
`include/image.mk` 的 `Image/BuildDTB` **直接用 cpp 编译**（`-I` 指向内核树的
`arch/arm64/boot/dts` 来解析 `#include`）。所以 `patches-6.18/` 这类 quilt 补丁
（只作用于内核源码）根本触不到这两个文件，放进去也不会生效，甚至可能让构建报错。

因此这里用「独立补丁 + 一键应用脚本」的方式，改动本身仍作为一个正常 commit
留在 `owrt` 分支上，补丁文件只是**同步上游丢失后的恢复手段**。

## 内容

| 补丁 | 目标文件 | 作用 |
|---|---|---|
| `0001-qualcommax-ax3600-edma-disable-tso.patch` | `dts/ipq8071-ax3600-stock.dts` | 给 `&edma` 加 `qcom,disable-tso`，消除 `qca-edma tx error 0x90000017/0x10000017` |
| `0002-qualcommax-ax3600-ax6-disable-usb.patch` | `dts/ipq8071-xiaomi.dtsi` | 关闭 `qusb_phy_0/1`、`ssphy_0/1`、`usb_0/1`（两机均无 USB 口） |

注意覆盖范围不同：`disable-tso` 只给 AX3600（AX6 实测 23 小时 0 条错误）；
USB 关闭放在被两机共用的 `ipq8071-xiaomi.dtsi`，一处覆盖四个镜像。

## 用法

在仓库根目录：

```sh
./local-patches/apply.sh
```

幂等：已生效的补丁会打印 `[skip]`；上下文有偏移时自动退回 `patch -p1 -l`；
无法应用时给出明确失败提示而不改动任何文件。

## 同步上游后的标准动作

```sh
git fetch upstream
git merge upstream/owrt        # 或 git rebase upstream/owrt

# 若这两个文件发生冲突：一律采用本地版本（丢弃上游对本文件的改动）
git checkout --ours target/linux/qualcommax/dts/ipq8071-ax3600-stock.dts
git checkout --ours target/linux/qualcommax/dts/ipq8071-xiaomi.dtsi
git add target/linux/qualcommax/dts/ipq8071-ax3600-stock.dts target/linux/qualcommax/dts/ipq8071-xiaomi.dtsi

./local-patches/apply.sh       # 兜底校验：应全部 [skip]
```

若上游哪天开始自己加了 `qcom,disable-tso` 或改了这两处，`apply.sh` 会打印
`[skip]` 或 `[FAIL]`，此时以脚本输出为准重新核对，不要盲目覆盖。

## 验证（刷机后）

```sh
# 1. disable-tso 属性进了 DTB
ls /sys/firmware/devicetree/base/soc@0/edma@3ab00000/
#    输出应含 qcom,disable-tso

# 2. USB 控制器 disabled
for n in $(find /sys/firmware/devicetree/base -name 'usb@*'); do
	echo "$n -> $(cat $n/status)"
done

# 3. edma 错误计数（基线 0.2~0.5 条/小时，24 小时后应仍为 0）
awk '/eth0/{print "tx_errors="$12, "tx_packets="$11}' /proc/net/dev
dmesg | grep -c 'qca-edma.*tx error'
```

> （注：部分内容由豆包 AI 生成）