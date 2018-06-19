/*
 * Copyright (C) 2018 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.lineageos.hardware;

import org.lineageos.internal.util.FileUtils;

import vendor.motorola.hardware.biometrics.fingerprint.V2_1.ExtBiometricsFingerprint;

/*
 * Disable fingerprint gestures
 */
public class KeyDisabler {
    private static final String NAV_PATH = "/sys/devices/platform/fingerprint/nav";

    private static ExtBiometricsFingerprint sExtBiometricsFingerprint;

    static {
        try {
            sExtBiometricsFingerprint = new ExtBiometricsFingerprint();
        } catch (Throwable t) {
            // Ignore, IExtBiometricsFingerprint is not available.
        }
    }

    /*
     * Always return true in our case
     */
    public static boolean isSupported() {
        return sExtBiometricsFingerprint != null && FileUtils.isFileReadable(NAV_PATH);
    }

    /*
     * Are the fingerprint gestures currently disabled?
     */
    public static boolean isActive() {
        return FileUtils.readOneLine(NAV_PATH).equals("1");
    }

    /*
     * Disable fingerprint gestures
     */
    public static boolean setActive(boolean state) {
        if (sExtBiometricsFingerprint == null) {
            return false;
        }
        sExtBiometricsFingerprint.sendCmdToHal(state
                ? ExtBiometricsFingerprint.MMI_TYPE_NAV_DISABLE
                : ExtBiometricsFingerprint.MMI_TYPE_NAV_ENABLE);
        return true;
    }
}
