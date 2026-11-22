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

## 6. USB 软件包瘦身（可选，针对 .config）

AX3600 与 AX6 都没有 USB 硬件，但 target 的 `DEFAULT_PACKAGES` 里仍带着
`kmod-usb3`、`kmod-usb-dwc3`、`kmod-usb-dwc3-qcom`、`kmod-usb-serial-qualcomm`，
`automount` 还会把 `kmod-usb-storage` 拖进来。这些包在 4 MiB 的 overlay 上属于纯浪费。

**不要改 `target/linux/qualcommax/Makefile`**（那会影响同 target 下真有 USB 口的设备），
只改自己仓库根目录的 `.config`：

```sh
# 1) 先生成 .config（二选一）
make menuconfig        # 或 make defconfig

# 2) 关掉死重量（幂等，可反复执行）
./local-patches/apply-config.sh

# 3) 看结果：6 项都应是 "# CONFIG_... is not set"
grep -E 'PACKAGE_kmod-usb|PACKAGE_automount' .config
```

脚本行为：

- 优先用仓库自带的 `./scripts/config --disable`；没有则退回 `sed`；
- 已经关掉的项打印 `[skip]`，不会重复改；
- 有改动时自动跑一次 `make olddefconfig` 收敛依赖；
- 若某项又变回 `=y`，说明被别的包 `select` 了，按名字继续往上关。

符号清单见 `config-usb-trim.txt`。

### 与上游同步时的注意

`.config` 通常不进 git（每次 `make menuconfig` 都会重写）。所以这一项**不是自动生效**的：
重新 `make defconfig` 或换 `.config` 之后，记得再跑一次 `apply-config.sh`。
它只影响构建产物，不碰源码，跟 0001/0002 两个 dts 补丁互不干扰。

> （注：部分内容由豆包 AI 生成）