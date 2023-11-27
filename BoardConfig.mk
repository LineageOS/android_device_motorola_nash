#
# Copyright (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Must set these before including common config
TARGET_BOARD_PLATFORM := msm8998
TARGET_BOOTLOADER_BOARD_NAME := Nash
TARGET_SUPPORTS_MOTO_MODS := true

# Inherit from motorola msm8998-common
include device/motorola/msm8998-common/BoardConfigCommon.mk

DEVICE_PATH := device/motorola/nash

# A/B updater
AB_OTA_UPDATER := true

AB_OTA_PARTITIONS += \
    boot \
    system \
    vendor

# Assertations
TARGET_BOARD_INFO_FILE := device/motorola/lake/board-info.txt
TARGET_OTA_ASSERT_DEVICE := nash

# Camera
MALLOC_SVELTE_FOR_LIBC32 := true

# Display
TARGET_SCREEN_DENSITY := 560

# HIDL
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/nash_manifest.xml

# Kernel
BOARD_KERNEL_CMDLINE += androidboot.boot_devices=soc/1da4000.ufshc
TARGET_KERNEL_CONFIG := lineageos_nash_defconfig

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 4378853376
BOARD_VENDORIMAGE_PARTITION_SIZE := 1409286144
TARGET_USES_OEM_AS_VENDOR := true

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# RIL
ENABLE_VENDOR_RIL_SERVICE := true

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# inherit from the proprietary version
include vendor/motorola/nash/BoardConfigVendor.mk
