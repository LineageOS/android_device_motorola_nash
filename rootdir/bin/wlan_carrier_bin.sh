#!/vendor/bin/sh
carrier=`getprop ro.carrier`

case "$carrier" in
    "retbr" | "timbr" | "tefbr" | "oibr" | "amxbr" | "niibr")
        echo -n bdwlan30_bra.bin > /sys/module/cnss_pci/parameters/regulatory_file
    ;;
    "perar" | "retar" | "tefar" | "amxar")
        echo -n bdwlan30_arg.bin > /sys/module/cnss_pci/parameters/regulatory_file
    ;;
    "retin" | "amzin")
        echo -n bdwlan30_ind.bin > /sys/module/cnss_pci/parameters/regulatory_file
    ;;
    * )
        echo -n bdwlan30.bin > /sys/module/cnss_pci/parameters/regulatory_file
    ;;
esac
