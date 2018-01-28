LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := optional

LOCAL_PACKAGE_NAME := ModPermsFix
LOCAL_CERTIFICATE := platform
LOCAL_PRIVILEGED_MODULE := true

include $(BUILD_PACKAGE)
