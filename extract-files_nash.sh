#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=nash
VENDOR=motorola

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

SECTION=
KANG=

while [ "$1" != "" ]; do
    case "$1" in
        -n | --no-cleanup )     CLEAN_VENDOR=false
                                ;;
        -k | --kang)            KANG="--kang"
                                ;;
        -s | --section )        shift
                                SECTION="$1"
                                CLEAN_VENDOR=false
                                ;;
        * )                     SRC="$1"
                                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC=adb
fi

function blob_fixup() {
    case "${1}" in
        # Load libSonyDefocus from vendor
        vendor/lib/libmmcamera_imx386.so)
            sed -i "s|/system/lib/hw/|/vendor/lib/hw/|g" "${2}"
            ;;
        # Load ZAF configs from vendor
        vendor/lib/libzaf_core.so)
            sed -i "s|/system/etc/zaf|/vendor/etc/zaf|g" "${2}"
            ;;
        # Load camera configs from vendor
        vendor/lib/libmmcamera2_sensor_modules.so)
            sed -i "s|/system/etc/camera/|/vendor/etc/camera/|g" "${2}"
            ;;
        # Drod unused dependency
        vendor/lib/libmmcamera_vstab_module.so)
            "${PATCHELF}" --remove-needed libandroid.so "${2}"
            ;;
        # Load camera metadata shim
        vendor/lib/hw/camera.msm8998.so)
            "${PATCHELF}" --replace-needed libcamera_client.so libcamera_metadata_helper.so "${2}"
            ;;
        # Correct mods gid
        etc/permissions/com.motorola.mod.xml)
            sed -i "s|vendor_mod|oem_5020|g" "${2}"
            ;;
        # Add uhid group for fingerprint service
        vendor/etc/init/android.hardware.biometrics.fingerprint@2.1-service.rc)
            sed -i "s/system input/system uhid input/" "${2}"
            ;;
        # Patch libcutils dep into audio HAL
        vendor/lib/hw/audio.primary.msm8998.so)
            "${PATCHELF}" --replace-needed "libcutils.so" "libprocessgroup.so" "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files_nash.txt" "${SRC}" ${KANG} --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
