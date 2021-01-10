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

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}"

# Copyright headers and guards
write_headers

write_makefiles "${MY_DIR}/proprietary-files.txt" true
write_makefiles "${MY_DIR}/proprietary-files_nash.txt" true

# Move MotCamera2 back to Android.mk prevent JNI dependency breakage
echo "include \$(CLEAR_VARS)" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
echo "LOCAL_MODULE := MotCamera2" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
echo "LOCAL_MODULE_OWNER := motorola" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
echo "LOCAL_SRC_FILES := proprietary/priv-app/MotCamera2/MotCamera2.apk" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
echo "LOCAL_CERTIFICATE := PRESIGNED" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
echo "LOCAL_MODULE_TAGS := optional" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
echo "LOCAL_MODULE_CLASS := APPS" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
echo "LOCAL_DEX_PREOPT := false" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
echo "LOCAL_MODULE_SUFFIX := .apk" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
echo "LOCAL_PRIVILEGED_MODULE := true" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
echo "LOCAL_REPLACE_PREBUILT_APK_INSTALLED := \$(LOCAL_PATH)/\$(LOCAL_SRC_FILES)" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
echo "LOCAL_NO_STANDARD_LIBRARIES := true" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
echo "include \$(BUILD_PREBUILT)" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
printf "\n" >> "${ANDROID_ROOT}/vendor/motorola/nash/Android.mk"
sed -i '/MotCamera2/,+10d' "${ANDROID_ROOT}/vendor/motorola/nash/Android.bp"


# Finish
write_footers
