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

import com.fingerprints.extension.V1_0.FingerprintNavigation;

/*
 * Disable fingerprint gestures
 */
public class KeyDisabler {
    private static FingerprintNavigation sFingerprintNavigation;

    static {
        try {
            sFingerprintNavigation = new FingerprintNavigation();
        } catch (Throwable t) {
            // Ignore, IFingerprintNavigation is not available.
        }
    }

    /*
     * Always return true in our case
     */
    public static boolean isSupported() {
        return sFingerprintNavigation != null;
    }

    /*
     * Are the fingerprint gestures currently disabled?
     */
    public static boolean isActive() {
        if (sFingerprintNavigation == null) {
            return false;
        }
        return sFingerprintNavigation.isEnabled();
    }

    /*
     * Disable fingerprint gestures
     */
    public static boolean setActive(boolean state) {
        if (sFingerprintNavigation == null) {
            return false;
        }
        sFingerprintNavigation.setNavigation(!state);
        return true;
    }
}
