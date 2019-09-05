#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
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

set -e

DEVICE=nash
VENDOR=motorola

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

LINEAGE_ROOT="$MY_DIR"/../../..

HELPER="$LINEAGE_ROOT"/vendor/lineage/build/tools/extract_utils.sh
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
. "$HELPER"

while [ "$1" != "" ]; do
    case $1 in
        -n | --no-cleanup )     CLEAN_VENDOR=false
                                ;;
        -s | --section )        shift
                                SECTION=$1
                                CLEAN_VENDOR=false
                                ;;
        * )                     SRC=$1
                                ;;
    esac
    shift
done

if [ -z "$SRC" ]; then
    SRC=adb
fi

# Initialize the helper
setup_vendor "$DEVICE" "$VENDOR" "$LINEAGE_ROOT" false "$CLEAN_VENDOR"

extract "$MY_DIR"/proprietary-files.txt "$SRC" "$SECTION"

BLOB_ROOT="$LINEAGE_ROOT"/vendor/"$VENDOR"/"$DEVICE"/proprietary

# Load libSonyDefocus from vendor
CAMERA_IMX386="$BLOB_ROOT"/vendor/lib/libmmcamera_imx386.so
sed -i "s|/system/lib/hw/|/vendor/lib/hw/|g" "$CAMERA_IMX386"

# Load ZAF configs from vendor
ZAF_CORE="$BLOB_ROOT"/vendor/lib/libzaf_core.so
sed -i "s|/system/etc/zaf|/vendor/etc/zaf|g" "$ZAF_CORE"

# Load camera configs from vendor
CAMERA2_SENSOR_MODULES="$BLOB_ROOT"/vendor/lib/libmmcamera2_sensor_modules.so
sed -i "s|/system/etc/camera/|/vendor/etc/camera/|g" "$CAMERA2_SENSOR_MODULES"

# Drod unused dependency
CAMERA_VSTAB_MODULES="$BLOB_ROOT"/vendor/lib/libmmcamera_vstab_module.so
patchelf --remove-needed libandroid.so "$CAMERA_VSTAB_MODULES"

# Load camera metadata shim
CAMERAHAL="$BLOB_ROOT"/vendor/lib/hw/camera.msm8998.so
patchelf --replace-needed libcamera_client.so libcamera_metadata_helper.so "$CAMERAHAL"

# Load wrapped shim
MDMCUTBACK="$BLOB_ROOT"/vendor/lib64/libmdmcutback.so
sed -i "s|libqsap_sdk.so|libqsapshim.so|g" "$MDMCUTBACK"

# Correct mods gid
MODPERM="$BLOB_ROOT"/etc/permissions/com.motorola.mod.xml
sed -i "s|vendor_mod|oem_5020|g" "$MODPERM"

# Correct qcrilhook library location
QCRILHOOK="$BLOB_ROOT"/vendor/etc/permissions/qcrilhook.xml
sed -i "s|/system/framework/qcrilhook.jar|/vendor/framework/qcrilhook.jar|g" "$QCRILHOOK"

# Correct QtiTelephonyServicelibrary location
TELESERVICELIB="$BLOB_ROOT"/vendor/etc/permissions/telephonyservice.xml
sed -i "s|/system/framework/QtiTelephonyServicelibrary.jar|/vendor/framework/QtiTelephonyServicelibrary.jar|g" "$TELESERVICELIB"

# Correct android.hidl.manager@1.0-java jar name
QTI_LIBPERMISSIONS="$BLOB_ROOT"/vendor/etc/permissions/qti_libpermissions.xml
sed -i "s|name=\"android.hidl.manager-V1.0-java|name=\"android.hidl.manager@1.0-java|g" "$QTI_LIBPERMISSIONS"

# Add uhid group for fingerprint service
FP_SERVICE_RC="$BLOB_ROOT"/vendor/etc/init/android.hardware.biometrics.fingerprint@2.1-service.rc
sed -i "s/input/uhid input/" "$FP_SERVICE_RC"

"$MY_DIR"/setup-makefiles.sh
