#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2019 The LineageOS Project
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

set -e

DEVICE=nash
VENDOR=motorola

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

LINEAGE_ROOT="${MY_DIR}/../../.."

HELPER="${LINEAGE_ROOT}/vendor/lineage/build/tools/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true
SECTION=
KANG=

# Introduce with nash option
WITH_NASH=false

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
        --nash)                 WITH_NASH=true
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
        patchelf --remove-needed libandroid.so "${2}"
        ;;

    # Load camera metadata shim
    vendor/lib/hw/camera.msm8998.so)
        patchelf --replace-needed libcamera_client.so libcamera_metadata_helper.so "${2}"
        ;;

    # Load wrapped shim
    vendor/lib64/libmdmcutback.so)
        sed -i "s|libqsap_sdk.so|libqsapshim.so|g" "${2}"
        ;;

    # Correct mods gid
    etc/permissions/com.motorola.mod.xml)
        sed -i "s|vendor_mod|oem_5020|g" "${2}"
        ;;

    # Correct qcrilhook library location
    vendor/etc/permissions/qcrilhook.xml)
        sed -i "s|/system/framework/qcrilhook.jar|/vendor/framework/qcrilhook.jar|g" "${2}"
        ;;

    # Correct QtiTelephonyServicelibrary location
    vendor/etc/permissions/telephonyservice.xml)
        sed -i "s|/system/framework/QtiTelephonyServicelibrary.jar|/vendor/framework/QtiTelephonyServicelibrary.jar|g" "${2}"
        ;;

    # Correct android.hidl.manager@1.0-java jar name
    vendor/etc/permissions/qti_libpermissions.xml)
        sed -i "s|name=\"android.hidl.manager-V1.0-java|name=\"android.hidl.manager@1.0-java|g" "${2}"
        ;;

    # Add uhid group for fingerprint service
    vendor/etc/init/android.hardware.biometrics.fingerprint@2.1-service.rc)
        sed -i "s/system input/system uhid input/" "${2}"
        ;;

    # Load libmot_gpu_mapper shim (file is pinned to prevent adding the same dependency multiple times if vendor blobs are regenerated)
    # vendor/lib/libmot_gpu_mapper.so)
        # patchelf --add-needed libgpu_mapper_shim.so "${2}"
        # ;;

    esac
}


# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${LINEAGE_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" ${KANG} --section "${SECTION}"

if [ "${WITH_NASH}" =  true ]; then
extract "${MY_DIR}/proprietary-files_nash.txt" "${SRC}" ${KANG} --section "${SECTION}"
fi

"${MY_DIR}/setup-makefiles.sh"
