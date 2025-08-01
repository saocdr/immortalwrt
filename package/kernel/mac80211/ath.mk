PKG_DRIVERS += \
	ath ath5k ath6kl ath6kl-sdio ath6kl-usb ath9k ath9k-common ath9k-htc ath10k ath10k-sdio ath10k-smallbuffers \
	ath11k ath11k-ahb ath11k-pci ath12k carl9170 owl-loader ar5523 wil6210 qcom-qmi-helpers

PKG_CONFIG_DEPENDS += \
	CONFIG_PACKAGE_ATH_DEBUG \
	CONFIG_PACKAGE_ATH_DFS \
	CONFIG_PACKAGE_ATH_SPECTRAL \
	CONFIG_PACKAGE_ATH_DYNACK \
	CONFIG_ATH9K_HWRNG \
	CONFIG_ATH9K_SUPPORT_PCOEM \
	CONFIG_ATH9K_TX99 \
	CONFIG_ATH10K_LEDS \
	CONFIG_ATH10K_THERMAL \
	CONFIG_ATH11K_THERMAL \
	CONFIG_ATH11K_DEBUGFS_STA \
	CONFIG_ATH11K_DEBUGFS_HTT_STATS \
	CONFIG_ATH_USER_REGD \
	CONFIG_ATH11K_MEM_PROFILE_1G \
	CONFIG_ATH11K_MEM_PROFILE_512M \
	CONFIG_ATH11K_MEM_PROFILE_256M \
	CONFIG_ATH11K_NSS_SUPPORT \
	CONFIG_ATH11K_NSS_MESH_SUPPORT

ifdef CONFIG_PACKAGE_MAC80211_DEBUGFS
  config-y += \
	ATH9K_DEBUGFS \
	ATH9K_HTC_DEBUGFS \
	ATH10K_DEBUGFS \
	ATH11K_DEBUGFS \
	ATH12K_DEBUGFS \
	CARL9170_DEBUGFS \
	ATH5K_DEBUG \
	ATH6KL_DEBUG \
	WIL6210_DEBUGFS
endif

ifdef CONFIG_PACKAGE_MAC80211_TRACING
  config-y += \
	ATH10K_TRACING \
	ATH11K_TRACING \
	ATH12K_TRACING \
	ATH6KL_TRACING \
	ATH_TRACEPOINTS \
	ATH5K_TRACER \
	WIL6210_TRACING
endif

config-$(call config_package,qcom-qmi-helpers) += QCOM_QMI_HELPERS
config-$(call config_package,ath,regular sdio smallbuffers) += ATH_CARDS ATH_COMMON
config-$(CONFIG_PACKAGE_ATH_DEBUG) += ATH_DEBUG ATH10K_DEBUG ATH11K_DEBUG ATH12K_DEBUG ATH9K_STATION_STATISTICS
config-$(CONFIG_PACKAGE_ATH_DFS) += ATH9K_DFS_CERTIFIED ATH10K_DFS_CERTIFIED
config-$(CONFIG_PACKAGE_ATH_SPECTRAL) += ATH9K_COMMON_SPECTRAL ATH10K_SPECTRAL ATH11K_SPECTRAL
config-$(CONFIG_PACKAGE_ATH_DYNACK) += ATH9K_DYNACK
config-$(call config_package,ath9k) += ATH9K
config-$(call config_package,ath9k-common) += ATH9K_COMMON
config-$(call config_package,owl-loader) += ATH9K_PCI_NO_EEPROM
config-$(CONFIG_TARGET_ath79) += ATH9K_AHB
config-$(CONFIG_TARGET_ipq40xx) += ATH10K_AHB
config-$(CONFIG_PCI) += ATH9K_PCI
config-$(CONFIG_ATH_USER_REGD) += ATH_USER_REGD ATH_REG_DYNAMIC_USER_REG_HINTS
config-$(CONFIG_ATH9K_HWRNG) += ATH9K_HWRNG
config-$(CONFIG_ATH9K_SUPPORT_PCOEM) += ATH9K_PCOEM
config-$(CONFIG_ATH9K_TX99) += ATH9K_TX99
config-$(CONFIG_ATH9K_UBNTHSR) += ATH9K_UBNTHSR
config-$(CONFIG_ATH10K_LEDS) += ATH10K_LEDS
config-$(CONFIG_ATH10K_THERMAL) += ATH10K_THERMAL
config-$(CONFIG_ATH11K_THERMAL) += ATH11K_THERMAL
config-$(CONFIG_ATH11K_MEM_PROFILE_1G) += ATH11K_MEM_PROFILE_1G
config-$(CONFIG_ATH11K_MEM_PROFILE_512M) += ATH11K_MEM_PROFILE_512M
config-$(CONFIG_ATH11K_MEM_PROFILE_256M) += ATH11K_MEM_PROFILE_256M
config-$(CONFIG_ATH11K_NSS_SUPPORT) += ATH11K_NSS_SUPPORT
config-$(CONFIG_ATH11K_NSS_MESH_SUPPORT) += ATH11K_NSS_MESH_SUPPORT
config-$(CONFIG_ATH11K_DEBUGFS_STA) += ATH11K_DEBUGFS_STA
config-$(CONFIG_ATH11K_DEBUGFS_HTT_STATS) += ATH11K_DEBUGFS_HTT_STATS

config-$(call config_package,ath9k-htc) += ATH9K_HTC
config-$(call config_package,ath10k,regular) += ATH10K ATH10K_PCI
config-$(call config_package,ath10k-sdio,sdio) += ATH10K ATH10K_SDIO
config-$(call config_package,ath10k-smallbuffers,smallbuffers) += ATH10K ATH10K_PCI ATH10K_SMALLBUFFERS
config-$(call config_package,ath11k) += ATH11K
config-$(call config_package,ath11k-ahb) += ATH11K_AHB
config-$(call config_package,ath11k-pci) += ATH11K_PCI
config-$(call config_package,ath12k) += ATH12K

config-$(call config_package,ath5k) += ATH5K ATH5K_PCI

config-$(call config_package,ath6kl) += ATH6KL
config-$(call config_package,ath6kl-sdio) += ATH6KL_SDIO
config-$(call config_package,ath6kl-usb) += ATH6KL_USB

config-$(call config_package,carl9170) += CARL9170
config-$(call config_package,ar5523) += AR5523

config-$(call config_package,wil6210) += WIL6210

define KernelPackage/ath/config
  if PACKAGE_kmod-ath
	config ATH_USER_REGD
		bool "Force Atheros drivers to respect the user's regdomain settings"
		default y
		help
		  Atheros' idea of regulatory handling is that the EEPROM of the card defines
		  the regulatory limits and the user is only allowed to restrict the settings
		  even further, even if the country allows frequencies or power levels that
		  are forbidden by the EEPROM settings.

		  Select this option if you want the driver to respect the user's decision about
		  regulatory settings.

	config PACKAGE_ATH_DEBUG
		bool "Atheros wireless debugging"
		help
		  Say Y, if you want to debug atheros wireless drivers.
		  Only ath9k & ath10k & ath11k make use of this.

	config PACKAGE_ATH_DFS
		bool "Enable DFS support"
		default y
		help
		  Dynamic frequency selection (DFS) is required for most of the 5 GHz band
		  channels in Europe, US, and Japan.

		  Select this option if you want to use such channels.

	config PACKAGE_ATH_SPECTRAL
		bool "Atheros spectral scan support"
		depends on PACKAGE_ATH_DEBUG
		select KERNEL_RELAY
		help
		  Say Y to enable access to the FFT/spectral data via debugfs.

	config PACKAGE_ATH_DYNACK
		bool "Enable Dynack support"
		depends on PACKAGE_kmod-ath9k-common
		help
		  Enables support for Dynamic ACK estimation, which allows the fastest possible speed
		  at any distance automatically by increasing/decreasing the max frame ACK time for
		  the most remote station detected.  It can be enabled by using iw (iw phy0 set distance auto),
		  or by sending the NL80211_ATTR_WIPHY_DYN_ACK flag to mac80211 driver using netlink.

		  Select this option if you want to enable this feature

  endif
endef

define KernelPackage/qcom-qmi-helpers
  $(call KernelPackage/mac80211/Default)
  TITLE:=Qualcomm QMI backports helpers
  HIDDEN:=1
  FILES:=$(PKG_BUILD_DIR)/drivers/soc/qcom/qmi_helpers.ko
  AUTOLOAD:=$(call AutoProbe,qmi_helpers)
endef

define KernelPackage/ath
  $(call KernelPackage/mac80211/Default)
  TITLE:=Atheros common driver part
  DEPENDS+= @PCI_SUPPORT||USB_SUPPORT||TARGET_ath79 +kmod-mac80211
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath.ko
  MENU:=1
endef

define KernelPackage/ath/description
 This module contains some common parts needed by Atheros Wireless drivers.
endef

define KernelPackage/ath5k
  $(call KernelPackage/mac80211/Default)
  TITLE:=Atheros 5xxx wireless cards support
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath5k
  DEPENDS+= @PCI_SUPPORT +kmod-ath
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath5k/ath5k.ko
  AUTOLOAD:=$(call AutoProbe,ath5k)
endef

define KernelPackage/ath5k/description
 This module adds support for wireless adapters based on
 Atheros 5xxx chipset.
endef

define KernelPackage/ath6kl
  $(call KernelPackage/mac80211/Default)
  TITLE:=Atheros FullMAC wireless devices (common code for ath6kl_sdio and ath6kl_usb)
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath6kl
  HIDDEN:=1
  DEPENDS+= +kmod-ath
  FILES:= $(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath6kl/ath6kl_core.ko
endef

define KernelPackage/ath6kl-sdio
  $(call KernelPackage/mac80211/Default)
  TITLE:=Atheros 802.11n SDIO wireless cards support
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath6kl
  DEPENDS+= +kmod-mmc +kmod-ath6kl
  FILES:= $(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath6kl/ath6kl_sdio.ko
  AUTOLOAD:=$(call AutoProbe,ath6kl_sdio)
endef

define KernelPackage/ath6kl-sdio/description
This module adds support for wireless adapters based on
Atheros IEEE 802.11n AR6003 and AR6004 family of chipsets.
endef

define KernelPackage/ath6kl-usb
  $(call KernelPackage/mac80211/Default)
  TITLE:=Atheros 802.11n USB wireless cards support
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath6kl
  DEPENDS+= @USB_SUPPORT +kmod-usb-core +kmod-ath6kl
  FILES:= $(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath6kl/ath6kl_usb.ko
  AUTOLOAD:=$(call AutoProbe,ath6kl_usb)
endef

define KernelPackage/ath6kl-usb/description
This module adds support for wireless adapters based on the
Atheros IEEE 802.11n AR6004 chipset.
endef

define KernelPackage/ath9k-common
  $(call KernelPackage/mac80211/Default)
  TITLE:=Atheros 802.11n wireless devices (common code for ath9k and ath9k_htc)
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath9k
  HIDDEN:=1
  DEPENDS+= @PCI_SUPPORT||USB_SUPPORT||TARGET_ath79 +kmod-ath +kmod-random-core
  FILES:= \
	$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath9k/ath9k_common.ko \
	$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath9k/ath9k_hw.ko
endef

define KernelPackage/ath9k
  $(call KernelPackage/mac80211/Default)
  TITLE:=Atheros 802.11n PCI wireless cards support
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath9k
  DEPENDS+= @PCI_SUPPORT||TARGET_ath79 +kmod-ath9k-common
  FILES:= \
	$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath9k/ath9k.ko
  AUTOLOAD:=$(call AutoProbe,ath9k)
endef

define KernelPackage/ath9k/description
This module adds support for wireless adapters based on
Atheros IEEE 802.11n AR5008 and AR9001 family of chipsets.
endef

define KernelPackage/ath9k/config

	config ATH9K_HWRNG
		bool "Add wireless noise as source of randomness to kernel entropy pool"
		depends on PACKAGE_kmod-ath9k
		select PACKAGE_kmod-random-core
		default y

	config ATH9K_SUPPORT_PCOEM
		bool "Support chips used in PC OEM cards"
		depends on PACKAGE_kmod-ath9k
		default y if (x86_64 || i386)

       config ATH9K_TX99
               bool "Enable TX99 support (WARNING: testing only, breaks normal operation!)"
               depends on PACKAGE_kmod-ath9k

	config ATH9K_UBNTHSR
		bool "Support for Ubiquiti UniFi Outdoor+ access point"
		depends on PACKAGE_kmod-ath9k && TARGET_ath79
		default y

endef

define KernelPackage/ath9k-htc
  $(call KernelPackage/mac80211/Default)
  TITLE:=Atheros 802.11n USB device support
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath9k
  DEPENDS+= @USB_SUPPORT +kmod-ath9k-common +kmod-usb-core +ath9k-htc-firmware
  FILES:= \
	$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath9k/ath9k_htc.ko
  AUTOLOAD:=$(call AutoProbe,ath9k_htc)
endef

define KernelPackage/ath9k-htc/description
This module adds support for wireless adapters based on
Atheros USB AR9271 and AR7010 family of chipsets.
endef

define KernelPackage/ath10k
  $(call KernelPackage/mac80211/Default)
  TITLE:=Atheros 802.11ac wireless cards support
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath10k
  DEPENDS+= @PCI_SUPPORT +kmod-ath +@DRIVER_11AC_SUPPORT \
	+ATH10K_THERMAL:kmod-hwmon-core +ATH10K_THERMAL:kmod-thermal
  FILES:= \
	$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath10k/ath10k_core.ko \
	$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath10k/ath10k_pci.ko
  AUTOLOAD:=$(call AutoProbe,ath10k_core ath10k_pci)
  MODPARAMS.ath10k_core:=frame_mode=2
  VARIANT:=regular
endef

define KernelPackage/ath10k/description
This module adds support for wireless adapters based on
Atheros IEEE 802.11ac family of chipsets. For now only
PCI is supported.
endef

define KernelPackage/ath10k/config

       config ATH10K_LEDS
               bool "Enable LED support"
               default y
               depends on PACKAGE_kmod-ath10k || PACKAGE_kmod-ath10k-smallbuffers

       config ATH10K_THERMAL
               bool "Enable thermal sensors and throttling support"
               default y
               depends on PACKAGE_kmod-ath10k || PACKAGE_kmod-ath10k-sdio || PACKAGE_kmod-ath10k-smallbuffers

endef

define KernelPackage/ath10k-sdio
  $(call KernelPackage/mac80211/Default)
  TITLE:=Atheros 802.11ac SDIO wireless cards support
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath10k
  DEPENDS+= +kmod-ath +kmod-mmc +@DRIVER_11AC_SUPPORT \
	+ATH10K_THERMAL:kmod-hwmon-core +ATH10K_THERMAL:kmod-thermal
  FILES:= \
	$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath10k/ath10k_core.ko \
	$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath10k/ath10k_sdio.ko
  AUTOLOAD:=$(call AutoProbe,ath10k_core)
  MODPARAMS.ath10k_core:=frame_mode=2
  VARIANT:=sdio
endef

define KernelPackage/ath10k-sdio/description
This module adds support for wireless adapters based on
Atheros IEEE 802.11ac family of chipsets with SDIO bus.
endef

define KernelPackage/ath10k-smallbuffers
  $(call KernelPackage/ath10k)
  TITLE+= (small buffers for low-RAM devices)
  VARIANT:=smallbuffers
endef

define KernelPackage/ath11k
  $(call KernelPackage/mac80211/Default)
  TITLE:=Qualcomm 802.11ax wireless chipset support (common code)
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath11k
  DEPENDS+= +kmod-ath +@DRIVER_11AC_SUPPORT +@DRIVER_11AX_SUPPORT \
  +kmod-crypto-michael-mic +ATH11K_THERMAL:kmod-hwmon-core \
  +ATH11K_THERMAL:kmod-thermal +kmod-qcom-qmi-helpers \
  +ATH11K_NSS_SUPPORT:kmod-qca-nss-drv \
  +ATH11K_NSS_MESH_SUPPORT:kmod-qca-nss-drv-wifi-meshmgr \
  +@(ATH11K_NSS_SUPPORT):NSS_DRV_WIFIOFFLOAD_ENABLE \
  +@(ATH11K_NSS_SUPPORT):NSS_DRV_WIFI_EXT_VDEV_ENABLE
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath11k/ath11k.ko
ifdef CONFIG_ATH11K_NSS_SUPPORT
  AUTOLOAD:=$(call AutoProbe,ath11k)
  MODPARAMS.ath11k:=nss_offload=1 frame_mode=2
endif
endef

define KernelPackage/ath11k/description
This module adds support for Qualcomm Technologies 802.11ax family of
chipsets.
endef

define KernelPackage/ath11k/conffiles
/etc/config/pbuf
endef

define KernelPackage/ath11k/config

       config ATH11K_THERMAL
               bool "Enable thermal sensors and throttling support"
               depends on PACKAGE_kmod-ath11k
               default y if TARGET_qualcommax

      config ATH11K_DEBUGFS_STA
               bool "Enable ath11k station statistics"
               depends on PACKAGE_kmod-ath11k
               depends on PACKAGE_MAC80211_DEBUGFS
               default y
               help
                  Say Y to enable access to the station statistics via debugfs.

      config ATH11K_DEBUGFS_HTT_STATS
               bool "Enable ath11k HTT statistics"
               depends on PACKAGE_kmod-ath11k
               depends on PACKAGE_MAC80211_DEBUGFS
               default y
               help
                  Say Y to enable access to the HTT statistics via debugfs.

       config ATH11K_NSS_SUPPORT
               bool "Enable NSS WiFi offload"
               select ATH11K_MEM_PROFILE_512M
               select PACKAGE_kmod-qca-nss-ecm
               default y
               help
                  Say Y to enable NSS WiFi offload support. Ensure you enable feeds for NSS drivers.
                  https://github.com/qosmio/nss-packages

       config ATH11K_NSS_MESH_SUPPORT
               bool "Enable NSS WiFi Mesh offload"
               depends on ATH11K_NSS_SUPPORT
               select PACKAGE_MAC80211_MESH
               select NSS_FIRMWARE_VERSION_11_4
               default n

       choice
            prompt "Memory Profile"
            depends on PACKAGE_kmod-ath11k
            default ATH11K_MEM_PROFILE_512M
            help
            	This option allows you to select the memory profile.
            	It should correspond to the total RAM of your board.

          config ATH11K_MEM_PROFILE_1G
               bool "Use 1G memory profile"
               help
                  This allows configuring ath11k for boards with 1GB+ memory.

          config ATH11K_MEM_PROFILE_512M
               bool "Use 512MB memory profile"
               help
                  This allows configuring ath11k for boards with 512M memory.
                  The default is 1GB if not selected

          config ATH11K_MEM_PROFILE_256M
               bool "Use 256MB memory profile"
               help
                  This allows configuring ath11k for boards with 256M memory.
                  The default is 1GB if not selected
       endchoice
endef

define KernelPackage/ath11k-ahb
  $(call KernelPackage/mac80211/Default)
  TITLE:=Qualcomm 802.11ax AHB wireless chipset support
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath11k
  DEPENDS+= @TARGET_qualcommax +kmod-ath11k +kmod-qrtr-smd
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath11k/ath11k_ahb.ko
  AUTOLOAD:=$(call AutoProbe,ath11k_ahb)
endef

define KernelPackage/ath11k-ahb/description
This module adds support for Qualcomm Technologies 802.11ax family of
chipsets with AHB bus.
endef

define KernelPackage/ath11k-pci
  $(call KernelPackage/mac80211/Default)
  TITLE:=Qualcomm 802.11ax PCI wireless chipset support
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath11k
  DEPENDS+= @PCI_SUPPORT +kmod-qrtr-mhi +kmod-ath11k
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath11k/ath11k_pci.ko
  AUTOLOAD:=$(call AutoProbe,ath11k_pci)
endef

define KernelPackage/ath11k-pci/description
This module adds support for Qualcomm Technologies 802.11ax family of
chipsets with PCI bus.
endef

define KernelPackage/ath12k
  $(call KernelPackage/mac80211/Default)
  TITLE:=Qualcomm 802.11be wireless chipset support
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/ath12k
  DEPENDS+= @PCI_SUPPORT +kmod-ath +@DRIVER_11AC_SUPPORT +@DRIVER_11AX_SUPPORT \
  +kmod-crypto-michael-mic +kmod-qrtr-mhi \
  +kmod-qcom-qmi-helpers +@DRIVER_11BE_SUPPORT
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath12k/ath12k.ko
  AUTOLOAD:=$(call AutoProbe,ath12k)
endef

define KernelPackage/ath12k/description
This module adds support for Qualcomm Technologies 802.11be family of
chipsets with PCI bus.
endef

define KernelPackage/carl9170
  $(call KernelPackage/mac80211/Default)
  TITLE:=Driver for Atheros AR9170 USB sticks
  DEPENDS:=@USB_SUPPORT +kmod-mac80211 +kmod-ath +kmod-usb-core +kmod-input-core +carl9170-firmware
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/ath/carl9170/carl9170.ko
  AUTOLOAD:=$(call AutoProbe,carl9170)
endef

define KernelPackage/owl-loader
  $(call KernelPackage/mac80211/Default)
  TITLE:=Owl loader for initializing Atheros PCI(e) Wifi chips
  DEPENDS:=@PCI_SUPPORT +kmod-ath9k
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ath9k/ath9k_pci_owl_loader.ko
  AUTOLOAD:=$(call AutoProbe,ath9k_pci_owl_loader)
endef

define KernelPackage/owl-loader/description
  Kernel module that helps to initialize certain Qualcomm
  Atheros' PCI(e) Wifi chips, which have the init data
  (which contains the PCI device ID for example) stored
  together with the calibration data in the file system.

  This is necessary for devices like the Cisco Meraki Z1.
endef

define KernelPackage/ar5523
  $(call KernelPackage/mac80211/Default)
  TITLE:=Driver for Atheros AR5523 USB sticks
  DEPENDS:=@USB_SUPPORT +kmod-mac80211 +kmod-ath +kmod-usb-core +kmod-input-core
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/ath/ar5523/ar5523.ko
  AUTOLOAD:=$(call AutoProbe,ar5523)
endef

define KernelPackage/wil6210
  $(call KernelPackage/mac80211/Default)
  TITLE:=QCA/Wilocity 60g WiFi card wil6210 support
  DEPENDS+= @PCI_SUPPORT +kmod-mac80211 +wil6210-firmware
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/ath/wil6210/wil6210.ko
  AUTOLOAD:=$(call AutoProbe,wil6210)
endef
