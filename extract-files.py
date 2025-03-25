#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

import extract_utils.tools

extract_utils.tools.DEFAULT_PATCHELF_VERSION = '0_9'

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)

from extract_utils.fixups_lib import (
    lib_fixup_vendorcompat,
    lib_fixups_user_type,
    libs_proto_3_9_1,
)

from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/motorola/nash',
    'device/motorola/msm8998-common',
    "hardware/qcom-caf/msm8998",
    "hardware/qcom-caf/wlan",
    'vendor/motorola/msm8998-common',
    "vendor/qcom/opensource/dataservices",
]

lib_fixups: lib_fixups_user_type = {
    libs_proto_3_9_1: lib_fixup_vendorcompat,
}

blob_fixups: blob_fixups_user_type = {
    'system/etc/permissions/com.motorola.mod.xml': blob_fixup()
        .regex_replace('vendor_mod', 'oem_5020'),
    (
        'system/lib64/libvibratorhw.so',
        'system/lib64/motorola.hardware.vibrator@1.0.so',
    ): blob_fixup()
        .replace_needed('libhidlbase.so', 'libhidlbase-v32.so'),
    'system/lib64/libmodhw.so': blob_fixup()
        .add_needed('libnativehelper_shim.so')
        .replace_needed('libhidlbase.so', 'libhidlbase-v32.so'),
    'vendor/bin/charge_only_mode': blob_fixup()
        .add_needed('libmemset_shim.so'),
    'vendor/etc/init/android.hardware.biometrics.fingerprint@2.1-service.rc': blob_fixup()
        .regex_replace('system input', 'system uhid input'),
    (
        'vendor/bin/hw/motorola.hardware.health@1.0-service',
        'vendor/lib/com.motorola.mod@1.0_vendor.so',
        'vendor/lib/libeqservicebridge.so',
        'vendor/lib/libmodmanager.so',
        'vendor/lib/motorola.hardware.audio.eqservice@1.0_vendor.so',
        'vendor/lib64/com.motorola.mod@1.0_vendor.so',
        'vendor/lib64/libmodmanager.so',
        'vendor/lib64/vendor.qti.hardware.tui_comm@1.0.so'
    ): blob_fixup()
        .replace_needed('libhidlbase.so', 'libhidlbase-v32.so')
        .replace_needed('libutils.so', 'libutils-v32.so'),
    'vendor/lib/libmmcamera_imx386.so': blob_fixup()
        .binary_regex_replace(b'\x2f\x73\x79\x73\x74\x65\x6d\x2f\x6c\x69\x62\x2f\x68\x77\x2f', b'\x2f\x76\x65\x6e\x64\x6f\x72\x2f\x6c\x69\x62\x2f\x68\x77\x2f'),
    (
        'vendor/lib/libmmcamera_tintless_bg_pca_algo.so',
        'vendor/lib64/libmmcamera_tintless_bg_pca_algo.so'
    ): blob_fixup()
        .add_needed('liblog.so'),
    'vendor/lib/libmmcamera_vstab_module.so': blob_fixup()
        .remove_needed('libandroid.so'),
    'vendor/lib/libmmcamera2_sensor_modules.so': blob_fixup()
        .binary_regex_replace(b'\x2f\x73\x79\x73\x74\x65\x6d\x2f\x65\x74\x63\x2f\x63\x61\x6d\x65\x72\x61\x2f', b'\x2f\x76\x65\x6e\x64\x6f\x72\x2f\x65\x74\x63\x2f\x63\x61\x6d\x65\x72\x61\x2f'),
    'vendor/lib/libzaf_core.so': blob_fixup()
        .binary_regex_replace(b'\x2f\x73\x79\x73\x74\x65\x6d\x2f\x65\x74\x63\x2f\x7a\x61\x66', b'\x2f\x76\x65\x6e\x64\x6f\x72\x2f\x65\x74\x63\x2f\x7a\x61\x66'),
    'vendor/lib/libtinyalsa-moto.so': blob_fixup()
        .fix_soname(),
    'vendor/lib/hw/audio.primary.msm8998-moto.so': blob_fixup()
        .replace_needed('libtinyalsa.so', 'libtinyalsa-moto.so')
        .replace_needed('libcutils.so', 'libprocessgroup.so')
        .replace_needed('libutils.so', 'libutils-v32.so')
        .fix_soname(),
    (
        'vendor/lib/libchromaflash.so',
        'vendor/lib/libdualcameraddm.so',
        'vendor/lib/libmmcamera_hdr_gb_lib.so',
        'vendor/lib/liboptizoom.so',
        'vendor/lib/libseemore.so',
        'vendor/lib/libtrueportrait.so',
        'vendor/lib/libubifocus.so',
        'vendor/lib/libvideobokeh.so',
        'vendor/lib64/libdualcameraddm.so',
        'vendor/lib64/libvideobokeh.so'
    ): blob_fixup()
        .replace_needed('libstdc++.so', 'libstdc++_vendor.so'),
    'vendor/lib/hw/camera.msm8998.so': blob_fixup()
        .replace_needed('libcamera_client.so', 'libcamera_metadata_helper.so'),
    (
        'vendor/lib/soundfx/libmmieffectswrapper.so',
        'vendor/lib/soundfx/libspeakerbundle.so'
    ): blob_fixup()
        .replace_needed('libtinyalsa.so', 'libtinyalsa-moto.so')
        .replace_needed('libutils.so', 'libutils-v32.so'),
    (
        'vendor/lib/libmotaudioutils.so',
        'vendor/lib/libtinycompress.so',
        'vendor/lib/libtinycompress_vendor.so'
    ): blob_fixup()
        .replace_needed('libutils.so', 'libutils-v32.so'),
}  # fmt: skip

module = ExtractUtilsModule(
    'nash',
    'motorola',
    namespace_imports=namespace_imports,
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
)

if __name__ == '__main__':
    utils = ExtractUtils.device_with_common(module, 'msm8998-common', module.vendor)
    utils.run()
