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

package com.fingerprints.extension.V1_0;

import android.os.HwBinder;
import android.os.HwParcel;
import android.os.IHwBinder;
import android.os.RemoteException;

public class FingerprintNavigation {
    private static final String DESCRIPTOR =
            "com.fingerprints.extension@1.0::IFingerprintNavigation";
    private static final int TRANSACTION_setNavigation = 1;
    private static final int TRANSACTION_isEnabled = 4;

    private static IHwBinder sFingerprintNavigation;

    public FingerprintNavigation() throws RemoteException {
        sFingerprintNavigation = HwBinder.getService(DESCRIPTOR, "default");
    }

    public void setNavigation(boolean enable) {
        if (sFingerprintNavigation == null) {
            //Log something here
            return;
        }

        HwParcel data = new HwParcel();
        HwParcel reply = new HwParcel();

        try {
            data.writeInterfaceToken(DESCRIPTOR);
            data.writeBool(enable);

            sFingerprintNavigation.transact(TRANSACTION_setNavigation, data, reply, 0);

            reply.verifySuccess();
            data.releaseTemporaryStorage();

            return;
        } catch (Throwable t) {
            //Log something else here
            return;
        } finally {
            reply.release();
        }
    }

    public boolean isEnabled() {
        if (sFingerprintNavigation == null) {
            //Log something here
            return false;
        }

        HwParcel data = new HwParcel();
        HwParcel reply = new HwParcel();

        try {
            data.writeInterfaceToken(DESCRIPTOR);

            sFingerprintNavigation.transact(TRANSACTION_isEnabled, data, reply, 0);

            reply.verifySuccess();
            data.releaseTemporaryStorage();

            boolean bl = reply.readBool();
            return bl;
        } catch (Throwable t) {
            //Log something else here
            return false;
        } finally {
            reply.release();
        }
    }
}
