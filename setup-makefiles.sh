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

cat << EOF >> "$ANDROIDMK"
include \$(CLEAR_VARS)
LOCAL_MODULE := MotCamera2
LOCAL_MODULE_OWNER := motorola
LOCAL_SRC_FILES := proprietary/priv-app/MotCamera2/MotCamera2.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_PRIVILEGED_MODULE := true
LOCAL_REPLACE_PREBUILT_APK_INSTALLED := \$(LOCAL_PATH)/\$(LOCAL_SRC_FILES)
include \$(BUILD_PREBUILT)

EOF

sed -i '/MotCamera2/,+10d' "${ANDROID_ROOT}/vendor/${VENDOR}/${DEVICE}/Android.bp"

# Finish
write_footers
