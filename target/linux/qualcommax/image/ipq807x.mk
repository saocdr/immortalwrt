DEVICE_VARS += NETGEAR_BOARD_ID NETGEAR_HW_ID TPLINK_SUPPORT_STRING

define Build/asus-fake-ramdisk
	rm -rf $(KDIR)/tmp/fakerd
	dd if=/dev/zero bs=32 count=1 > $(KDIR)/tmp/fakerd
	$(info KERNEL_INITRAMFS is $(KERNEL_INITRAMFS))
endef

define Build/asus-fake-rootfs
	$(eval comp=$(word 1,$(1)))
	$(eval filepath=$(word 2,$(1)))
	$(eval filecont=$(word 3,$(1)))
	rm -rf $(KDIR)/tmp/fakefs $(KDIR)/tmp/fakehsqs
	mkdir -p $(KDIR)/tmp/fakefs/$$(dirname $(filepath))
	echo '$(filecont)' > $(KDIR)/tmp/fakefs/$(filepath)
	$(STAGING_DIR_HOST)/bin/mksquashfs4 $(KDIR)/tmp/fakefs $(KDIR)/tmp/fakehsqs -comp $(comp) \
		-b 4096 -no-exports -no-sparse -no-xattrs -all-root -noappend \
		$(wordlist 4,$(words $(1)),$(1))
endef

define Build/asus-trx
	$(STAGING_DIR_HOST)/bin/asusuimage $(wordlist 1,$(words $(1)),$(1)) -i $@ -o $@.new
	mv $@.new $@
endef

define Build/wax6xx-netgear-tar
	mkdir $@.tmp
	mv $@ $@.tmp/nand-ipq807x-apps.img
	md5sum $@.tmp/nand-ipq807x-apps.img | cut -c 1-32 > $@.tmp/nand-ipq807x-apps.md5sum
	echo $(DEVICE_MODEL) > $@.tmp/metadata.txt
	echo $(DEVICE_MODEL)"_V99.9.9.9" > $@.tmp/version
	tar -C $@.tmp/ -cf $@ .
	rm -rf $@.tmp
endef

define Device/aliyun_ap8220
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Aliyun
	DEVICE_MODEL := AP8220
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8071
	DEVICE_DTS_CONFIG := config@ac02
	DEVICE_PACKAGES := ipq-wifi-aliyun_ap8220 kmod-hci-uart kmod-bluetooth kmod-bluetooth-6lowpan
endef
TARGET_DEVICES += aliyun_ap8220

define Device/arcadyan_aw1000
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Arcadyan
	DEVICE_MODEL := AW1000
	BLOCKSIZE := 256k
	PAGESIZE := 4096
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@hk09
	DEVICE_PACKAGES := ipq-wifi-arcadyan_aw1000 kmod-gpio-nxp-74hc164 kmod-usb-serial-option uqmi
endef
TARGET_DEVICES += arcadyan_aw1000

define Device/asus_rt-ax89x
	DEVICE_VENDOR := Asus
	DEVICE_MODEL := RT-AX89X
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8074
	DEVICE_DTS_CONFIG := config@hk01
	DEVICE_PACKAGES := ipq-wifi-asus_rt-ax89x kmod-hwmon-gpiofan
	KERNEL_NAME := vmlinux
	KERNEL := kernel-bin | libdeflate-gzip
	KERNEL_IN_UBI := 1
	IMAGE/sysupgrade.bin/squashfs := \
		append-kernel | asus-fake-ramdisk |\
		multiImage gzip $$(KDIR)/tmp/fakerd $$(KDIR)/image-$$(DEVICE_DTS).dtb |\
		sysupgrade-tar kernel=$$$$@ | append-metadata
ifneq ($(CONFIG_TARGET_ROOTFS_INITRAMFS),)
	ARTIFACTS := initramfs-factory.trx initramfs-uImage.itb
	ARTIFACT/initramfs-uImage.itb := \
		append-image-stage initramfs-kernel.bin | fit gzip $$(KDIR)/image-$$(DEVICE_DTS).dtb
	ARTIFACT/initramfs-factory.trx := \
		append-image-stage initramfs-kernel.bin |\
		asus-fake-rootfs xz /lib/firmware/IPQ8074A/fw_version.txt "fake" -no-compression |\
		multiImage gzip $$(KDIR)/tmp/fakehsqs $$(KDIR)/image-$$(DEVICE_DTS).dtb |\
		asus-trx -v 2 -n RT-AX89U -b 388 -e 49000
endif
endef
TARGET_DEVICES += asus_rt-ax89x

define Device/buffalo_wxr-5950ax12
	$(call Device/FitImage)
	DEVICE_VENDOR := Buffalo
	DEVICE_MODEL := WXR-5950AX12
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8074
	DEVICE_DTS_CONFIG := config@hk01
	DEVICE_PACKAGES := ipq-wifi-buffalo_wxr-5950ax12
endef
TARGET_DEVICES += buffalo_wxr-5950ax12

define Device/cmcc_rm2-6
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := CMCC
	DEVICE_MODEL := RM2-6
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8070
	DEVICE_DTS_CONFIG := config@ac02
	DEVICE_PACKAGES := ipq-wifi-cmcc_rm2-6 kmod-hwmon-gpiofan
	IMAGES += factory.bin
	IMAGE/factory.bin := append-ubi | qsdk-ipq-factory-nand
endef
TARGET_DEVICES += cmcc_rm2-6

define Device/compex_wpq873
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Compex
	DEVICE_MODEL := WPQ873
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@hk09.wpq873
	DEVICE_PACKAGES := ipq-wifi-compex_wpq873
	IMAGE/factory.ubi := append-ubi | qsdk-ipq-factory-nand
endef
TARGET_DEVICES += compex_wpq873

define Device/dynalink_dl-wrx36
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Dynalink
	DEVICE_MODEL := DL-WRX36
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@rt5010w-d350-rev0
	DEVICE_PACKAGES := ipq-wifi-dynalink_dl-wrx36
endef
TARGET_DEVICES += dynalink_dl-wrx36

define Device/edgecore_eap102
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Edgecore
	DEVICE_MODEL := EAP102
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8071
	DEVICE_DTS_CONFIG := config@ac02
	DEVICE_PACKAGES := ipq-wifi-edgecore_eap102
	IMAGE/factory.ubi := append-ubi | qsdk-ipq-factory-nand
endef
TARGET_DEVICES += edgecore_eap102

define Device/edimax_cax1800
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Edimax
	DEVICE_MODEL := CAX1800
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8070
	DEVICE_DTS_CONFIG := config@ac03
	DEVICE_PACKAGES := ipq-wifi-edimax_cax1800
endef
TARGET_DEVICES += edimax_cax1800

define Device/linksys_homewrk
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Linksys
	DEVICE_MODEL := HomeWRK
	IMAGE_SIZE := 475m
	NAND_SIZE := 1024m
	BLOCKSIZE := 256k
	PAGESIZE := 4096
	SOC := ipq8174
	DEVICE_DTS_CONFIG := config@oak03
	DEVICE_PACKAGES += ipq-wifi-linksys_homewrk kmod-leds-pca963x
endef
TARGET_DEVICES += linksys_homewrk

define Device/linksys_mx
	$(call Device/FitImage)
	DEVICE_VENDOR := Linksys
	KERNEL_SIZE := 6144k
	IMAGE_SIZE := 147456k
	NAND_SIZE := 512m
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8072
	DEVICE_PACKAGES := kmod-leds-pca963x kmod-hci-uart
	IMAGES += factory.bin
	IMAGE/factory.bin := append-kernel | pad-to $$$$(KERNEL_SIZE) | append-ubi | linksys-image type=$$$$(DEVICE_MODEL)
endef

define Device/linksys_mx4x00
	$(call Device/linksys_mx)
	SOC := ipq8174
	DEVICE_PACKAGES += ipq-wifi-linksys_mx4200
endef

define Device/linksys_mx4200v1
	$(call Device/linksys_mx4x00)
	DEVICE_MODEL := MX4200
	DEVICE_VARIANT := v1
endef
TARGET_DEVICES += linksys_mx4200v1

define Device/linksys_mx4200v2
	$(call Device/linksys_mx4200v1)
	DEVICE_VARIANT := v2
endef
TARGET_DEVICES += linksys_mx4200v2

define Device/linksys_mx4300
	$(call Device/linksys_mx4x00)
	DEVICE_MODEL := MX4300
	KERNEL_SIZE := 8192k
	IMAGE_SIZE := 171264k
	NAND_SIZE := 1024m
	BLOCKSIZE := 256k
	PAGESIZE := 4096
endef
TARGET_DEVICES += linksys_mx4300

define Device/linksys_mx5300
	$(call Device/linksys_mx)
	DEVICE_MODEL := MX5300
	DEVICE_PACKAGES += ipq-wifi-linksys_mx5300 ath10k-firmware-qca9984 kmod-ath10k kmod-rtc-ds1307
endef
TARGET_DEVICES += linksys_mx5300

define Device/linksys_mx8500
	$(call Device/linksys_mx)
	DEVICE_MODEL := MX8500
	DEVICE_PACKAGES += ipq-wifi-linksys_mx8500 ath11k-firmware-qcn9074 kmod-hci-uart
endef
TARGET_DEVICES += linksys_mx8500

define Device/netgear_rax120v2
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Netgear
	DEVICE_MODEL := RAX120v2
	KERNEL_SIZE := 29696k
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8074
	DEVICE_DTS_CONFIG := config@hk01
	DEVICE_PACKAGES := ipq-wifi-netgear_rax120v2 kmod-spi-bitbang kmod-gpio-nxp-74hc164 kmod-hwmon-g762
	NETGEAR_BOARD_ID := RAX120
	NETGEAR_HW_ID := 29765589+0+512+1024+4x4+8x8
ifneq ($(CONFIG_TARGET_ROOTFS_INITRAMFS),)
	IMAGES += web-ui-factory.img
	IMAGE/web-ui-factory.img := append-image initramfs-uImage.itb | pad-offset $$$$(BLOCKSIZE) 64 | append-uImage-fakehdr filesystem | netgear-dni
endif
	IMAGE/sysupgrade.bin := append-kernel | pad-offset $$$$(BLOCKSIZE) 64 | append-uImage-fakehdr filesystem | sysupgrade-tar kernel=$$$$@ | append-metadata
endef
TARGET_DEVICES += netgear_rax120v2

define Device/netgear_sxk80
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_PACKAGES += ipq-wifi-netgear_sxk80
	DEVICE_VENDOR := Netgear
	KERNEL_SIZE := 6272k
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8074
	DEVICE_DTS_CONFIG := config@hk01
	NETGEAR_HW_ID := 29766265+0+512+1024+4x4+4x4+4x4
endef

define Device/netgear_sxr80
	$(call Device/netgear_sxk80)
	DEVICE_MODEL := SXR80
	NETGEAR_BOARD_ID := SXR80
endef
TARGET_DEVICES += netgear_sxr80

define Device/netgear_sxs80
	$(call Device/netgear_sxk80)
	DEVICE_MODEL := SXS80
	NETGEAR_BOARD_ID := SXS80
endef
TARGET_DEVICES += netgear_sxs80

define Device/netgear_wax218
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Netgear
	DEVICE_MODEL := WAX218
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@hk07
ifneq ($(CONFIG_TARGET_ROOTFS_INITRAMFS),)
	ARTIFACTS := web-ui-factory.fit
	ARTIFACT/web-ui-factory.fit := append-image initramfs-uImage.itb | ubinize-kernel | qsdk-ipq-factory-nand
endif
	DEVICE_PACKAGES := ipq-wifi-netgear_wax218 kmod-spi-bitbang kmod-gpio-nxp-74hc164
endef
TARGET_DEVICES += netgear_wax218

define Device/netgear_wax620
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Netgear
	DEVICE_MODEL := WAX620
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@hk07
	DEVICE_PACKAGES := ipq-wifi-netgear_wax620 kmod-gpio-nxp-74hc164
	IMAGES += ui-factory.tar
	IMAGE/ui-factory.tar := append-ubi | qsdk-ipq-factory-nand | pad-to 4096 | wax6xx-netgear-tar
endef
TARGET_DEVICES += netgear_wax620

define Device/netgear_wax630
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Netgear
	DEVICE_MODEL := WAX630
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8074
	DEVICE_DTS_CONFIG := config@hk01
	DEVICE_PACKAGES := ipq-wifi-netgear_wax630
	IMAGES += ui-factory.tar
	IMAGE/ui-factory.tar := append-ubi | qsdk-ipq-factory-nand | pad-to 4096 | wax6xx-netgear-tar
endef
TARGET_DEVICES += netgear_wax630

define Device/prpl_haze
	$(call Device/FitImage)
	$(call Device/EmmcImage)
	DEVICE_VENDOR := prpl Foundation
	DEVICE_MODEL := Haze
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@hk09
	DEVICE_PACKAGES := ipq-wifi-prpl_haze ath11k-firmware-qcn9074 kmod-leds-lp5562
endef
TARGET_DEVICES += prpl_haze

define Device/qnap_301w
	$(call Device/FitImage)
	$(call Device/EmmcImage)
	DEVICE_VENDOR := QNAP
	DEVICE_MODEL := 301w
	KERNEL_SIZE := 16384k
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@hk01
	DEVICE_PACKAGES := ipq-wifi-qnap_301w
endef
TARGET_DEVICES += qnap_301w

define Device/redmi_ax6
	$(call Device/xiaomi_ax3600)
	DEVICE_VENDOR := Redmi
	DEVICE_MODEL := AX6
	DEVICE_PACKAGES := ipq-wifi-redmi_ax6
endef
TARGET_DEVICES += redmi_ax6

define Device/redmi_ax6-stock
	$(call Device/redmi_ax6)
	DEVICE_VARIANT := (stock layout)
	DEVICE_ALT0_VENDOR := Redmi
	DEVICE_ALT0_MODEL := AX6
	DEVICE_ALT0_VARIANT := (custom U-Boot layout)
	KERNEL_SIZE :=
	ARTIFACTS :=
endef
TARGET_DEVICES += redmi_ax6-stock

define Device/spectrum_sax1v1k
	$(call Device/FitImage)
	$(call Device/EmmcImage)
	DEVICE_VENDOR := Spectrum
	DEVICE_MODEL := SAX1V1K
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@rt5010w-d187-rev6
	DEVICE_PACKAGES := ipq-wifi-spectrum_sax1v1k
	IMAGES := sysupgrade.bin
endef
TARGET_DEVICES += spectrum_sax1v1k

define Device/tplink_deco-x80-5g
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := TP-Link
	DEVICE_MODEL := Deco X80-5G
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8074
	DEVICE_DTS_CONFIG := config@hk01.c5
	DEVICE_PACKAGES := ipq-wifi-tplink_deco-x80-5g kmod-hwmon-gpiofan kmod-usb-serial-option kmod-usb-net-qmi-wwan
endef
TARGET_DEVICES += tplink_deco-x80-5g

define Device/tplink_eap620hd-v1
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := TP-Link
	DEVICE_MODEL := EAP620 HD
	DEVICE_VARIANT := v1
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8072
	DEVICE_PACKAGES := ipq-wifi-tplink_eap620hd-v1
	IMAGES += web-ui-factory.bin
	IMAGE/web-ui-factory.bin := append-ubi | tplink-image-2022
	TPLINK_SUPPORT_STRING := SupportList:\r\nEAP620 HD(TP-Link|UN|AX1800-D):1.0\r\n
endef
TARGET_DEVICES += tplink_eap620hd-v1

define Device/tplink_eap660hd-v1
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := TP-Link
	DEVICE_MODEL := EAP660 HD
	DEVICE_VARIANT := v1
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8072
	DEVICE_PACKAGES := ipq-wifi-tplink_eap660hd-v1
	IMAGES += web-ui-factory.bin
	IMAGE/web-ui-factory.bin := append-ubi | tplink-image-2022
	TPLINK_SUPPORT_STRING := SupportList:\r\nEAP660 HD(TP-Link|UN|AX3600-D):1.0\r\n
endef
TARGET_DEVICES += tplink_eap660hd-v1

define Device/xiaomi_ax3600
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Xiaomi
	DEVICE_MODEL := AX3600
	DEVICE_VARIANT := (OpenWrt expand layout)
	KERNEL_SIZE := 36608k
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8071
	DEVICE_DTS_CONFIG := config@ac04
	DEVICE_PACKAGES := ipq-wifi-xiaomi_ax3600 ath10k-firmware-qca9887 kmod-ath10k-smallbuffers
ifneq ($(CONFIG_TARGET_ROOTFS_INITRAMFS),)
	ARTIFACTS := initramfs-factory.ubi
	ARTIFACT/initramfs-factory.ubi := append-image-stage initramfs-uImage.itb | ubinize-kernel
endif
endef
TARGET_DEVICES += xiaomi_ax3600

define Device/xiaomi_ax3600-stock
	$(call Device/xiaomi_ax3600)
	DEVICE_VARIANT := (stock layout)
	DEVICE_ALT0_VENDOR := Xiaomi
	DEVICE_ALT0_MODEL := AX3600
	DEVICE_ALT0_VARIANT := (custom U-Boot layout)
	KERNEL_SIZE :=
	ARTIFACTS :=
endef
TARGET_DEVICES += xiaomi_ax3600-stock

define Device/xiaomi_ax9000
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Xiaomi
	DEVICE_MODEL := AX9000
	DEVICE_VARIANT := (OpenWrt expand layout)
	KERNEL_SIZE := 57344k
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@hk14
	DEVICE_PACKAGES := ipq-wifi-xiaomi_ax9000 ath11k-firmware-qcn9074 ath10k-firmware-qca9887 kmod-ath10k-smallbuffers
ifneq ($(CONFIG_TARGET_ROOTFS_INITRAMFS),)
	ARTIFACTS := initramfs-factory.ubi
	ARTIFACT/initramfs-factory.ubi := append-image-stage initramfs-uImage.itb | ubinize-kernel
endif
endef
TARGET_DEVICES += xiaomi_ax9000

define Device/xiaomi_ax9000-stock
	$(call Device/xiaomi_ax9000)
	DEVICE_VARIANT := (stock layout)
	DEVICE_ALT0_VENDOR := Xiaomi
	DEVICE_ALT0_MODEL := AX9000
	DEVICE_ALT0_VARIANT := (custom U-Boot layout)
	KERNEL_SIZE :=
	ARTIFACTS :=
endef
TARGET_DEVICES += xiaomi_ax9000-stock

define Device/yuncore_ax880
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Yuncore
	DEVICE_MODEL := AX880
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@hk09
	DEVICE_PACKAGES := ipq-wifi-yuncore_ax880
	IMAGES += factory.bin
	IMAGE/factory.bin := append-ubi | qsdk-ipq-factory-nand
endef
TARGET_DEVICES += yuncore_ax880

define Device/zbtlink_zbt-z800ax
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Zbtlink
	DEVICE_MODEL := ZBT-Z800AX
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@hk09
	DEVICE_PACKAGES := ipq-wifi-zbtlink_zbt-z800ax
	IMAGES += factory.bin
	IMAGE/factory.bin := append-ubi | qsdk-ipq-factory-nand
endef
TARGET_DEVICES += zbtlink_zbt-z800ax

define Device/zte_mf269
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := ZTE
	DEVICE_MODEL := MF269
	DEVICE_VARIANT := (OpenWrt expand layout)
	KERNEL_SIZE := 53248k
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8071
	DEVICE_DTS_CONFIG := config@ac04
	DEVICE_PACKAGES := ipq-wifi-zte_mf269
	DEVICE_COMPAT_VERSION := 1.1
	DEVICE_COMPAT_MESSAGE := Partition table has changed, please flash new stock layout firmware instead
endef
TARGET_DEVICES += zte_mf269

define Device/zte_mf269-stock
	$(call Device/zte_mf269)
	DEVICE_VARIANT := (stock layout)
	DEVICE_ALT0_VENDOR := ZTE
	DEVICE_ALT0_MODEL := MF269
	DEVICE_ALT0_VARIANT := (custom U-Boot layout)
	KERNEL_SIZE :=
endef
TARGET_DEVICES += zte_mf269-stock

define Device/zyxel_nbg7815
	$(call Device/FitImage)
	$(call Device/EmmcImage)
	DEVICE_VENDOR := ZYXEL
	DEVICE_MODEL := NBG7815
	SOC := ipq8074
	DEVICE_DTS_CONFIG := config@nbg7815
	DEVICE_PACKAGES := ipq-wifi-zyxel_nbg7815 kmod-hci-uart kmod-hwmon-tmp103
endef
TARGET_DEVICES += zyxel_nbg7815

define Device/verizon_cr1000a
	$(call Device/FitImage)
	$(call Device/EmmcImage)
	DEVICE_VENDOR := Verizon
	DEVICE_MODEL := CR1000A
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@verizon_cr1000a
	DEVICE_PACKAGES := ipq-wifi-verizon_cr1000a ath11k-firmware-qcn9074 kmod-phy-realtek
endef
TARGET_DEVICES += verizon_cr1000a
