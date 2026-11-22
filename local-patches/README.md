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

## 6. USB 软件包瘦身（可选）

AX3600 与 AX6 都没有 USB 硬件，但 target 的 `DEFAULT_PACKAGES` 里仍带着
`kmod-usb3`、`kmod-usb-dwc3`、`kmod-usb-dwc3-qcom`、`kmod-usb-serial-qualcomm`，
`automount` 还会把 `kmod-usb-storage` 拖进来。这些包在 4 MiB 的 overlay 上属于纯浪费。

**不要改 `target/linux/qualcommax/Makefile`**（那会影响同 target 下真有 USB 口的设备，
如 ax9000、mx8500、qnap 301w）。按构建方式二选一：

### 6.1 走 CI（saocdr/OpenWRT-CI）

改 **`Config/IPQ807X-WIFI-YES.txt`**，在设备列表之后追加：

```
#AX3600 / AX6 无USB口，精简无用USB组件
CONFIG_PACKAGE_kmod-usb3=n
CONFIG_PACKAGE_kmod-usb-dwc3=n
CONFIG_PACKAGE_kmod-usb-dwc3-qcom=n
CONFIG_PACKAGE_kmod-usb-serial-qualcomm=n
CONFIG_PACKAGE_kmod-usb-storage=n
CONFIG_PACKAGE_automount=n
```

原因：`WRT-CORE.yml` 第 188/190 行把 `Config/<平台>.txt`（及 `GENERAL.txt`）追加进
`.config`，第 196 行再 `make defconfig`，所以显式 `=n` 会覆盖 `DEFAULT_PACKAGES`。
**不要写进 `GENERAL.txt`**——它被 x86 / mediatek / rockchip 等所有平台共用。

验证：构建完从 Actions artifact 下载 `Config-IPQ807X-*.txt`，
`grep -E 'PACKAGE_kmod-usb|PACKAGE_automount'` 应为 6 行 `is not set`。

### 6.2 走本地编译（make menuconfig / defconfig）

```sh
make menuconfig        # 或 make defconfig
./local-patches/apply-config.sh
grep -E 'PACKAGE_kmod-usb|PACKAGE_automount' .config
```

脚本优先用 `./scripts/config --disable`，没有则退 `sed`；已关项打印 `[skip]`；
有改动会自动跑 `make olddefconfig`。符号清单见 `config-usb-trim.txt`。

### 6.3 注意

- `.config` 被 `.gitignore` 忽略（`/.config`），**不会进仓库**，所以 CI 只能靠上面的 Config txt；
- 本地每次重新生成 `.config` 后都要再跑一次 `apply-config.sh`；
- 若日后在 `IPQ807X-WIFI-YES.txt` 里启用带 USB 口的设备（qnap_301w、mx8500、ax9000、
  cr1000a），记得把 6.1 那 6 行删掉。

> （注：部分内容由豆包 AI 生成）