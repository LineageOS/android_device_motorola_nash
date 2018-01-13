#!/system/vendor/bin/sh
# High assurance boot image verification service
# Checks system image, oem image, or both depending on "which_image"

if [[ $1 == "complete" ]]; then
    error=`/vendor/bin/getprop hab.error`
    updating=`/vendor/bin/getprop ro.boot.updating`
    if [[ -z $error ]]; then
        if [[ $updating == "1" ]]; then
             /vendor/bin/bl_notify --set --hab-notify "HAB_SV_UPGRADE"
        else
             /vendor/bin/bl_notify --set --hab-notify "HAB_OK"
        fi
    fi
    exit 0
fi

which_image=$1

product=`/vendor/bin/getprop ro.boot.hab.product`
cid=`/vendor/bin/getprop ro.boot.hab.cid`
csv=`/vendor/bin/getprop ro.boot.hab.csv`
secure_hw=`/vendor/bin/getprop ro.boot.secure_hardware`
verified_boot_state=`/vendor/bin/getprop ro.boot.verifiedbootstate`

do_hab_error()
{
    echo "HAB verify failed. Reason: $1"

    # notify BL of the failure
    nice -n -20 /vendor/bin/bl_notify --set --hab-notify "HAB_FAIL:$1"

    setprop hab.error "HAB_FAIL:$1"

    if [ $secure_hw == "1" ] && [ $verified_boot_state == "green" ]; then
        echo "HAB verify failed with reason: $1. Rebooting ..." > /dev/kmsg
        nice -n -15 /vendor/bin/setprop sys.powerctl reboot
    fi

    exit 1
}

value_from_key()
{ 
    value=""
    key=$1
    filename=$2

    if [ -e $filename  ]; then
        value=`/vendor/bin/toybox_vendor grep $key $filename | cut -d " " -f 2,3,4,5 | tr -cd [:alnum:]`
    fi

    if [ -z $value ]; then
       value="unknown"
    fi
}

verify_system()
{
    system_file="/system/etc/system_sign_info"

    value_from_key "HAB_PRODUCT" "$system_file"
    system_product=$value
    value_from_key "HAB_CID" "$system_file"
    system_cid=$value
    value_from_key "HAB_SECURITY_VERSION" "$system_file"
    system_csv=$value

    echo "verifying system:"
    echo "  product:$system_product"
    echo "  cid:$system_cid"
    echo "  csv:$system_csv"

    if [ $product != $system_product ]; then
        do_hab_error "SYSTEM_PRODUCT_CHECK"
    fi

    if [ $cid != $system_cid ]; then
        do_hab_error "SYSTEM_CID_CHECK"
    fi

    if [ $csv != $system_csv ]; then
        do_hab_error "SYSTEM_CSV_CHECK"
    fi

    setprop hab.system.verified true
}

verify_oem()
{
    oem_file="/oem/etc/oem_sign_info"
    oem_verified=`/vendor/bin/getprop partition.oem.verified`

    value_from_key "HAB_PRODUCT" "$oem_file"
    oem_product=$value
    value_from_key "HAB_CID" "$oem_file"
    oem_cid=$value
    value_from_key "HAB_SECURITY_VERSION" "$oem_file"
    oem_csv=$value

    echo "Verifying oem:"
    echo "  product:$oem_product"
    echo "  cid:$oem_cid"
    echo "  csv:$oem_csv"

    if [ -z "$(ls -A /oem)" ]; then
        do_hab_error "OEM_MISSING"
    fi

    # This property is set to one of the "enum verity_mode" values when enabled.
    # All are OK for boot.
    if [ -z $oem_verified ]; then
        do_hab_error "OEM_UNVERIFIED"
    fi
 
    if [ $product != $oem_product ]; then
        do_hab_error "OEM_PRODUCT_CHECK"
    fi

    if [ $cid != $oem_cid ]; then
        do_hab_error "OEM_CID_CHECK"
    fi

    if [ $csv != $oem_csv ]; then
        do_hab_error "OEM_CSV_CHECK"
    fi

    setprop hab.oem.verified true
}

verify_vendor()
{
    vendor_file="/vendor/etc/vendor_sign_info"
    vendor_verified=`/vendor/bin/getprop partition.vendor.verified`

    value_from_key "HAB_PRODUCT" "$vendor_file_file"
    vendor_file_product=$value
    value_from_key "HAB_CID" "$vendor_file_file"
    vendor_file_cid=$value
    value_from_key "HAB_SECURITY_VERSION" "$vendor_file_file"
    vendor_file_csv=$value

    echo "Verifying vendor:"
    echo "  product:$vendor_product"
    echo "  cid:$vendor_cid"
    echo "  csv:$vendor_csv"

    if [ -z "$(ls -A /vendor)" ]; then
        do_hab_error "VENDOR_MISSING"
    fi

    # This property is set to one of the "enum verity_mode" values when enabled.
    # All are OK for boot.
    if [ -z $vendor_verified ]; then
        do_hab_error "VENDOR_UNVERIFIED"
    fi

    if [ $product != $vendor_product ]; then
        do_hab_error "VENDOR_PRODUCT_CHECK"
    fi

    if [ $cid != $vendor_cid ]; then
        do_hab_error "VENDOR_CID_CHECK"
    fi

    if [ $csv != $vendor_csv ]; then
        do_hab_error "VENDOR_CSV_CHECK"
    fi

    setprop hab.vendor.verified true
}

if [ -z $product ]; then
    do_hab_error "NO_PRODUCT"
fi

if [ $product == "unknown" ]; then
    do_hab_error "UNKNOWN_PRODUCT"
fi

if [ -z $cid ]; then
    do_hab_error "NO_CID"
fi

if [ -z $csv ]; then
    do_hab_error "NO_CSV"
fi

echo "expected:"
echo "  product:$product"
echo "  cid:$cid"
echo "  csv:$csv"

if [[ $which_image != "other" ]]; then
    verify_system
fi

if [[ $which_image != "system" ]]; then
    oem_mount=`/vendor/bin/cat /vendor/etc/fstab* | /vendor/bin/toybox_vendor grep "/oem "`
    if [ ! -z "$oem_mount" ]; then
        verify_oem
    fi
    vendor_mount=`/vendor/bin/cat /vendor/etc/fstab* | /vendor/bin/toybox_vendor grep "/vendor "`
    if [ ! -z "$vendor_mount" ]; then
        verify_vendor
    fi
fi

exit 0
