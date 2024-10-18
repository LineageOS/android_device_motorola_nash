# Inherit some common Lineage stuff.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Device
$(call inherit-product, device/motorola/nash/device.mk)

# Device identifiers
PRODUCT_BRAND := motorola
PRODUCT_DEVICE := nash
PRODUCT_MANUFACTURER := motorola
PRODUCT_MODEL := Moto Z (2)
PRODUCT_NAME := lineage_nash

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="nash-user 9 PPX29.159-24 e78f1 release-keys" \
    BuildFingerprint=motorola/nash_retail/nash:9/PPX29.159-24/e78f1:user/release-keys \
    DeviceName=nash
