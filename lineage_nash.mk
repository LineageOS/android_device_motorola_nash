# Inherit some common Lineage stuff.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# Vendor blobs
$(call inherit-product-if-exists, vendor/motorola/nash/nash-vendor.mk)
$(call inherit-product-if-exists, vendor/motorola/nash/mods-vendor.mk)

# Device
$(call inherit-product, device/motorola/nash/device.mk)

# A/B updater
AB_OTA_UPDATER := true

AB_OTA_PARTITIONS += \
    boot \
    system \
    vendor

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

PRODUCT_PACKAGES += \
    otapreopt_script \
    update_engine \
    update_engine_sideload \
    update_verifier

# The following modules are included in debuggable builds only.
PRODUCT_PACKAGES_DEBUG += \
    bootctl \
    update_engine_client

# Boot Animtion
TARGET_BOOTANIMATION_HALF_RES := true

# Boot control HAL
PRODUCT_PACKAGES += \
    bootctrl.qcom

PRODUCT_STATIC_BOOT_CONTROL_HAL := \
    bootctrl.qcom \
    libcutils \
    libgptutils \
    libz

# Overlays
DEVICE_PACKAGE_OVERLAYS += device/motorola/nash/overlay

PRODUCT_ENFORCE_RRO_TARGETS := \
    framework-res

# TWRP
ifeq ($(WITH_TWRP),true)
$(call inherit-product, device/motorola/nash/twrp/twrp.mk)
else
TARGET_RECOVERY_FSTAB := device/motorola/nash/rootdir/etc/fstab.qcom
endif

# Device identifiers
PRODUCT_DEVICE := nash
PRODUCT_NAME := lineage_nash
PRODUCT_BRAND := motorola
PRODUCT_MODEL := Moto Z2
PRODUCT_MANUFACTURER := Motorola
PRODUCT_RELEASE_NAME := nash

PRODUCT_BUILD_PROP_OVERRIDES += \
        PRODUCT_NAME=nash

BUILD_FINGERPRINT := motorola/nash/nash:8.0.0/OPXS27.109-34-10/5:user/release-keys
