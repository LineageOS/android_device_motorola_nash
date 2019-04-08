# Inherit some common Lineage stuff.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# Vendor blobs
$(call inherit-product-if-exists, vendor/motorola/nash/nash-vendor.mk)

# Installs gsi keys into ramdisk, to boot a GSI with verified boot.
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)

# Device
$(call inherit-product, device/motorola/nash/device.mk)

# Boot Animtion
TARGET_BOOTANIMATION_HALF_RES := true


# Device identifiers
BUILD_FINGERPRINT := motorola/nash/nash:8.0.0/OPXS27.109-34-10/5:user/release-keys
PRODUCT_BRAND := motorola
PRODUCT_DEVICE := nash
PRODUCT_MANUFACTURER := Motorola
PRODUCT_MODEL := Moto Z2
PRODUCT_NAME := lineage_nash
PRODUCT_RELEASE_NAME := nash

PRODUCT_BUILD_PROP_OVERRIDES += \
        PRODUCT_NAME=nash
