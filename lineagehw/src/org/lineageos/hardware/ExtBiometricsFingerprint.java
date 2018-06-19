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

package vendor.motorola.hardware.biometrics.fingerprint.V2_1;

import android.os.HwBinder;
import android.os.HwParcel;
import android.os.IHwBinder;
import android.os.RemoteException;

public class ExtBiometricsFingerprint {
    public static final int MMI_TYPE_NAV_ENABLE = 41;
    public static final int MMI_TYPE_NAV_DISABLE = 42;

    private static final String DESCRIPTOR =
            "vendor.motorola.hardware.biometrics.fingerprint@2.1::IExtBiometricsFingerprint";
    private static final int TRANSACTION_sendCmdToHal = 20;

    private static IHwBinder sBiometricsFingerprint;

    public ExtBiometricsFingerprint() throws RemoteException {
        sBiometricsFingerprint = HwBinder.getService(DESCRIPTOR, "default");
    }

    public int sendCmdToHal(int cmdId) {
        if (sBiometricsFingerprint == null) {
            return -1;
        }

        HwParcel data = new HwParcel();
        HwParcel reply = new HwParcel();

        try {
            data.writeInterfaceToken(DESCRIPTOR);
            data.writeInt32(cmdId);

            sBiometricsFingerprint.transact(TRANSACTION_sendCmdToHal, data, reply, 0);

            reply.verifySuccess();
            data.releaseTemporaryStorage();

            return reply.readInt32();
        } catch (Throwable t) {
            return -1;
        } finally {
            reply.release();
        }
    }
}
