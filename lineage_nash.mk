# Inherit from those products, most specific first
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/product_launched_with_n_mr1.mk)

# Inherit from nash device
$(call inherit-product, device/motorola/nash/device.mk)

# Inherit some common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_nash
PRODUCT_DEVICE := nash
PRODUCT_MANUFACTURER := motorola
PRODUCT_BRAND := motorola
PRODUCT_MODEL := Moto Z (2)

PRODUCT_BUILD_PROP_OVERRIDES += \
        PRODUCT_NAME=nash \
        PRIVATE_BUILD_DESC="nash-user 9 PPX29.159-24 e78f1 release-keys"

BUILD_FINGERPRINT := motorola/nash_retail/nash:9/PPX29.159-24/e78f1:user/release-keys
